#!/bin/bash
set -euo pipefail

readonly USAGE="Usage: provision.sh [-l | -c <command_name>]"

main() {
  while getopts ":lch" opt; do
    case ${opt} in
      l)
        declare -F | awk '{ print $3 }' | grep -vE "(main|git_clone)"
        exit 0
        ;;
      c)
        shift $((OPTIND - 1))
        for command in "$@"; do
          $command
        done
        exit 0
        ;;
      h)
        echo "$USAGE"
        exit 0
        ;;
      \?)
        echo "Invalid option: $OPTARG" 1>&2
        echo "$USAGE"
        exit 1
        ;;
    esac
  done
  shift $((OPTIND - 1))
  echo ">>> Installing everything..."
  mkdir_home_user_bin
  setup_non_root_npm_install_global
  install_gotools
  install_docker
  install_ohmyzsh
  install_tanzu_cli
  uninstall_vim_plug
  install_nvim_extensions
  install_cred_alert
  configure_dotfiles
  clone_git_repos
  install_misc_tools
  install_pure_zsh_theme
  install_tmux_plugin_manager
  install_zsh_autosuggestions
  switch_to_zsh
}

mkdir_home_user_bin() {
  mkdir -p "$HOME/bin"
}

setup_non_root_npm_install_global() {
  mkdir -p "${HOME}/.npm-packages"
  npm config set prefix "${HOME}/.npm-packages"
}

install_cred_alert() {
  os_name=$(uname | awk '{print tolower($1)}')
  curl -o cred-alert-cli \
    "https://s3.amazonaws.com/cred-alert/cli/current-release/cred-alert-cli_${os_name}"
  chmod 755 cred-alert-cli
  mv cred-alert-cli "$HOME/bin/"
}

install_docker() {
  echo ">>> Installing Docker"
  if command -v docker; then
    sudo apt upgrade docker-ce docker-ce-cli docker-ce-rootless-extras -y
  else
    curl -fsSL get.docker.com | sudo sh
    sudo usermod -aG docker "$USER"
  fi
}

install_gotools() {
  echo ">>> Installing golangci-lint"
  local url
  url="$(curl -sSfL https://api.github.com/repos/golangci/golangci-lint/releases/latest | jq -r '.assets[]|select(.name|match("linux-amd64.deb")).browser_download_url')"
  curl -sSfLo golangci-lint.deb "$url"
  sudo dpkg --install golangci-lint.deb
  rm -f golangci-lint.deb

  echo ">>> Installing gopls"
  go install golang.org/x/tools/gopls@latest

  echo ">>> Installing setup-envtest"
  go install sigs.k8s.io/controller-runtime/tools/setup-envtest@latest
}

install_ohmyzsh() {
  echo ">>> Installing Oh My Zsh"
  [ ! -d "$HOME/.oh-my-zsh" ] && sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  # Delete default .zshrc to avoid stow conflicts
  rm -f "$HOME/.zshrc"
}

install_tmux_plugin_manager() {
  echo ">>> Installing TPM"
  git_clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
}

install_zsh_autosuggestions() {
  echo ">>> Installing zsh-autosuggestions"
  git_clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
}

uninstall_vim_plug() {
  # remove it now we've switched to lazy plugin manager
  rm -f "$HOME/.local/share/nvim/site/autoload/plug.vim"
}

install_nvim_extensions() {
  echo ">>> Installing the NeoVim extensions"
  npm install -g neovim
  gem install neovim --user-install
}

clone_git_repos() {
  echo ">>> Cloning our Git repositories"

  mkdir -p "$HOME/workspace"
  pushd "$HOME/workspace"
  {
    git_clone "git@github.com:kieron-dev/station.git" "" main
    git_clone "git@gitlab.eng.vmware.com:tap-public-cloud/tap-sandbox/tap-recipe.git" "$HOME/workspace/tap-sandbox/tap-recipe" main
    git_clone "git@gitlab.eng.vmware.com:tap-public-cloud/tap-sandbox/environment-controller.git" "$HOME/workspace/tap-sandbox/environment-controller" main
  }

  popd
}

git_clone() {
  local url path name branch
  url=$1
  path=${2:-""}
  branch=${3:-""}

  if [ -z "$path" ]; then
    name=${url%%.git}
    name=${name##*/}
    path="$HOME/workspace/$name"
  fi

  if [ -d "$path" ]; then
    echo "Repository $path already exists. Skipping git clone..."
    return
  fi

  git clone "$url" "$path"

  if [ -f "$path/.gitmodules" ]; then
    git -C "$path" submodule update --init --recursive
  fi

  if [ -n "$branch" ]; then
    git -C "$path" switch "$branch"
  fi
}

configure_dotfiles() {
  echo ">>> Installing eirini-home"

  ssh-keyscan -t rsa github.com >>"$HOME/.ssh/known_hosts"

  git_clone "git@github.com:pivotal-cf/git-hooks-core.git"
  git_clone "git@github.com:kieron-dev/station-home.git" "" "main"

  pushd "$HOME/workspace/station-home"
  {
    git checkout main
    git pull -r
    ./install.sh

    export GIT_DUET_CO_AUTHORED_BY=1
    export GIT_DUET_GLOBAL=true
    git duet ae ae # initialise git-duet
    git init       # install git-duet hooks on eirini-home
  }
  popd
}

install_misc_tools() {
  echo ">>> Installing Ginkgo"
  go install github.com/onsi/ginkgo/v2/ginkgo@latest

  echo ">>> Installing concourse-flake-hunter"
  go install github.com/eirini-forks/concourse-flake-hunter@latest

  echo ">>> Installing fly"
  curl -sL "https://ci.korifi.cf-app.com/api/v1/cli?arch=amd64&platform=linux" -o "$HOME/bin/fly"
  chmod +x "$HOME/bin/fly"

  echo ">>> Installing k9s"
  curl -LsSf https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz | tar xvzf - -C "$HOME/bin" k9s

  echo ">>> Installing kind"
  curl -LsSf https://github.com/kubernetes-sigs/kind/releases/latest/download/kind-linux-amd64 -o "$HOME/bin/kind"
  chmod +x "$HOME/bin/kind"

  echo ">>> Installing shfmt"
  go install mvdan.cc/sh/v3/cmd/shfmt@latest
}

install_pure_zsh_theme() {
  echo ">>> Installing the pure prompt"
  mkdir -p "$HOME/.zsh"
  git_clone "https://github.com/sindresorhus/pure.git" "$HOME/.zsh/pure"
  pushd "$HOME/.zsh/pure"
  {
    # pure have switched from `master` to `main` for their main branch
    # TODO remove this once everyone has been migrated
    if git show-ref --quiet refs/heads/master; then
      git branch -m master main
      git branch --set-upstream-to=origin/main
    fi
    git pull -r
  }
  popd
}

install_tanzu_cli() {
  echo ">>> Installing tanzu CLI"
  curl -sSfLo tanzu.tar.gz "https://github.com/vmware-tanzu/tanzu-cli/releases/latest/download/tanzu-cli-linux-amd64.tar.gz"
  f="$(tar tf tanzu.tar.gz | grep tanzu-cli)"
  tar -xvf tanzu.tar.gz "$f"
  install "$f" "$HOME/bin/tanzu"
  rm -rf tanzu.tar.gz "$(dirname $f)"
  tanzu init
  tanzu config set env.TANZU_CLI_ADDITIONAL_PLUGIN_DISCOVERY_IMAGES_TEST_ONLY harbor-repo.vmware.com/tanzu_cli_stage/plugins/plugin-inventory:latest
  tanzu plugin install --group vmware-tap/default:1.6.0-rc.1
}

switch_to_zsh() {
  echo ">>> Setting Zsh as the default shell"
  sudo chsh -s /bin/zsh "$(whoami)"
}

main "$@"
