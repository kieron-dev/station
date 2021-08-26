#!/bin/bash
set -euo pipefail

readonly USAGE="Usage: provision.sh [-l | -c <command_name>]"

main() {
  while getopts ":lch" opt; do
    case ${opt} in
      l)
        declare -F | awk '{ print $3 }' | grep -vE "(main|go_get|git_clone)"
        exit 0
        ;;
      c)
        shift $((OPTIND - 1))
        for command in $@; do
          $command
        done
        exit 0
        ;;
      h)
        echo $USAGE
        exit 0
        ;;
      \?)
        echo "Invalid option: $OPTARG" 1>&2
        echo $USAGE
        exit 1
        ;;
    esac
  done
  shift $((OPTIND - 1))
  echo ">>> Installing everything..."
  mkdir_home_user_bin
  install_gotools
  install_docker
  install_ohmyzsh
  install_vim_plug
  install_nvim_extensions
  install_rbenv
  install_cred_alert
  configure_dotfiles
  clone_git_repos
  install_vim_plugins
  install_misc_tools
  install_pure_zsh_theme
  install_tmux_plugin_manager
  install_zsh_autosuggestions
  init_pass_store
  configure_gpg
  switch_to_zsh
}

mkdir_home_user_bin() {
  mkdir -p $HOME/bin
}

install_cred_alert() {
  os_name=$(uname | awk '{print tolower($1)}')
  curl -o cred-alert-cli \
    https://s3.amazonaws.com/cred-alert/cli/current-release/cred-alert-cli_${os_name}
  chmod 755 cred-alert-cli
  mv cred-alert-cli "$HOME/bin/"
}

install_docker() {
  echo ">>> Installing Docker"
  if command -v docker; then
    sudo apt upgrade docker-ce docker-ce-cli docker-ce-rootless-extras -y
  else
    curl -fsSL get.docker.com | sudo sh
    sudo usermod -aG docker $USER
  fi
}

install_gotools() {
  echo ">>> Installing golangci-lint"
  curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b "$HOME/go/bin/" v1.42.0

  echo ">>> Installing gopls"
  GO111MODULE=on go_get golang.org/x/tools/gopls@latest

  echo ">>> Installing fillstruct"
  go_get -u github.com/davidrjenni/reftools/cmd/fillstruct

  echo ">>> Installing gomodifytags"
  go_get -u github.com/fatih/gomodifytags

  echo ">>> Installing keyify"
  go_get -u honnef.co/go/tools/cmd/keyify

  echo ">>> Installing goimports"
  go_get -u golang.org/x/tools/cmd/goimports

  echo ">>> Installing gci"
  go_get -u github.com/daixiang0/gci

  echo ">>> Installing gotags"
  go_get -u github.com/jstemmer/gotags
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
  git_clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
}

install_vim_plug() {
  echo ">>> Installing vim-plug"
  curl -fLo "$HOME/.local/share/nvim/site/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
}

install_nvim_extensions() {
  echo ">>> Installing the NeoVim extensions"
  sudo npm install -g neovim
  pip3 install --upgrade pip
  pip3 install --upgrade neovim
  gem install neovim --user-install
}

install_rbenv() {
  local ruby_version=2.7.2
  echo ">>> Installing Ruby $ruby_version with rbenv"

  local rbenv_root
  rbenv_root="$HOME/.rbenv"

  if [[ ! -d "$rbenv_root" ]]; then
    git_clone https://github.com/rbenv/rbenv.git "$rbenv_root"

    mkdir -p "$rbenv_root/plugins"
    git_clone https://github.com/rbenv/ruby-build.git "$rbenv_root/plugins/ruby-build"
  fi

  if ! "$rbenv_root/bin/rbenv" versions | grep -q "$ruby_version"; then
    PATH="$rbenv_root/bin:$PATH" rbenv install "$ruby_version"
  fi
}

clone_git_repos() {
  echo ">>> Cloning our Git repositories"

  mkdir -p "$HOME/workspace"
  pushd "$HOME/workspace"
  {
    git_clone "git@github.com:cloudfoundry-incubator/eirini-ci.git"
    git_clone "git@github.com:cloudfoundry-incubator/eirini-release.git" "" develop
    git_clone "git@github.com:cloudfoundry-incubator/eirini.git"
    git_clone "git@github.com:cloudfoundry-incubator/eirini-controller.git"
    git_clone "git@github.com:cloudfoundry/capi-k8s-release.git"
    git_clone "git@github.com:cloudfoundry/capi-release.git"
    git_clone "git@github.com:cloudfoundry/cf-for-k8s.git"
    add_remote cf-for-k8s ef "git@github.com:eirini-forks/cf-for-k8s.git"
    git_clone "git@github.com:eirini-forks/eirini-station.git"
  }
  popd
}

add_remote() {
  local path remote_uri remote_name
  path="$1"
  remote_name="$2"
  remote_uri="$3"

  if ! git -C "$path" remote -v | grep -q "^$remote_name\b"; then
    git -C "$path" remote add "$remote_name" "$remote_uri"
    git -C "$path" fetch "$remote_name"
  fi
}

git_clone() {
  local url path name branch
  url=$1
  path=${2:-""}
  branch=${3:-""}

  if [ -z "$path" ]; then
    name=$(echo "$url" | sed 's/\.git//g' | cut -d / -f 2)
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
  git_clone "git@github.com:cloudfoundry/eirini-private-config.git"
  git_clone "git@github.com:eirini-forks/eirini-home.git"

  pushd "$HOME/workspace/eirini-home"
  {
    git checkout master
    git pull -r
    ./install.sh

    export GIT_DUET_CO_AUTHORED_BY=1
    export GIT_DUET_GLOBAL=true
    git duet ae ae # initialise git-duet
    git init       # install git-duet hooks on eirini-home
  }
  popd
}

install_vim_plugins() {
  echo ">>> Installing the NeoVim plugins"
  nvim --headless +PlugInstall +PlugUpdate +UpdateRemotePlugins +qall
}

install_misc_tools() {
  echo ">>> Installing Gomega"
  go_get -u "github.com/onsi/gomega"

  echo ">>> Installing Ginkgo"
  go_get -u "github.com/onsi/ginkgo/ginkgo"

  echo ">>> Installing Counterfeiter"
  GO111MODULE=off go_get -u "github.com/maxbrunsfeld/counterfeiter"

  echo ">>> Installing concourse-flake-hunter"
  go_get -u "github.com/masters-of-cats/concourse-flake-hunter"

  echo ">>> Installing fly"
  curl -sL "https://jetson.eirini.cf-app.com/api/v1/cli?arch=amd64&platform=linux" -o "$HOME/bin/fly" && chmod +x "$HOME/bin/fly"

  echo ">>> Installing flightattendant"
  go_get -u "github.com/masters-of-cats/flightattendant"

  echo ">>> Installing k9s (v0.24.15)"
  curl -L https://github.com/derailed/k9s/releases/download/v0.24.15/k9s_Linux_x86_64.tar.gz | tar xvzf - -C "$HOME/bin" k9s

  echo ">>> Installing kind (v0.11.1)"
  curl -L https://github.com/kubernetes-sigs/kind/releases/download/v0.11.1/kind-linux-amd64 -o "$HOME/bin/kind"
  chmod +x "$HOME/bin/kind"

  echo ">>> Installing promql-cli (v0.2.1)"
  curl -L https://github.com/nalbury/promql-cli/releases/download/v0.2.1/promql-v0.2.1-linux-amd64.tar.gz | tar xvzf - -C "$HOME/bin" promql
  chmod +x "$HOME/bin/promql"

  echo ">>> Installing kubeval (v0.15.0)"
  curl -L https://github.com/instrumenta/kubeval/releases/download/0.15.0/kubeval-linux-amd64.tar.gz | tar xvzf - -C "$HOME/bin" kubeval
  chmod +x "$HOME/bin/kubeval"
}

go_get() {
  /usr/local/go/bin/go get "$@"
}

init_pass_store() {
  echo ">>> Initialising the pass store"
  mkdir -p "$HOME/.password-store"
  ln -sfn "$HOME/workspace/eirini-private-config/pass/eirini" "$HOME/.password-store/"
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

switch_to_zsh() {
  echo ">>> Setting Zsh as the default shell"
  sudo chsh -s /bin/zsh "$(whoami)"
}

configure_gpg() {
  mkdir -p ~/.gnupg
  chmod 700 ~/.gnupg
  cat <<EOF >~/.gnupg/gpg.conf
no-autostart
pinentry-mode loopback
EOF
}

main $@
