#!/bin/bash
set -exuo pipefail

main() {
  install_ibmcloud_cli
  setup_helm_client
  install_golangcilint
  install_ohmyzsh
  install_vim_plug
  install_vim_extensions
  clone_git_repos
  configure_dotfiles
  setup_pass
  install_vim_plugins
  install_misc_tools
  install_pure_zsh_theme
  compile_authorized_keys
  init_pass_store
  switch_to_zsh
}

install_ibmcloud_cli(){
  curl -sL https://ibm.biz/idt-installer | bash
  ibmcloud plugin install kubernetes-service -f
}

setup_helm_client() {
  helm init --client-only
}

install_golangcilint() {
  curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b "$HOME/go/bin" v1.24.0
}

install_ohmyzsh() {
  [ ! -d "$HOME/.oh-my-zsh" ] && sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  # Delete default .zshrc to avoid stow conflicts
  rm -f "$HOME/.zshrc"
}

install_vim_plug() {
  curl -fLo "$HOME/.local/share/nvim/site/autoload/plug.vim" --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
}

install_vim_extensions() {
  sudo npm install -g neovim
  pip3 install --upgrade pip
  pip3 install --upgrade neovim
  gem install neovim --user-install
}

clone_git_repos() {
  ssh-keyscan -t rsa github.com >> "$HOME/.ssh/known_hosts"

  mkdir -p "$HOME/workspace"
  pushd "$HOME/workspace"
    git_clone "git@github.com:cloudfoundry-incubator/eirini-ci.git"
    git_clone "git@github.com:cloudfoundry-incubator/eirini-release.git"
    git_clone "git@github.com:cloudfoundry-incubator/eirini-staging.git"
    git_clone "git@github.com:cloudfoundry-incubator/eirini.git"
    git_clone "git@github.com:cloudfoundry/eirini-private-config.git"
    git_clone "git@github.com:eirini-forks/eirini-home.git"
    git_clone "git@github.com:eirini-forks/eirini-station.git"
  popd
}

git_clone() {
  local url path name
  url=$1
  path=${2:-""}

  if [ -z "$path" ]; then
    name=$(echo "$url" | sed 's/.git//g' | cut -d / -f 2)
    path="$HOME/workspace/$name"
  fi

  if [ -d "$path" ]; then
    echo "Repository $path already exists. Skipping git clone..."
    return
  fi

  git clone "$url" "$path"
}

configure_dotfiles() {
  pushd "$HOME/workspace/eirini-home"
    git checkout vagrant
    ./install.sh
  popd
}

setup_pass() {
  pass init eirini
  ln -sfn ~/workspace/eirini-private-config/pass/eirini ~/.password-store/
}

install_vim_plugins() {
  nvim --headless +PlugInstall +PlugUpdate +UpdateRemotePlugins +qall
  PATH="$PATH:/usr/local/go/bin" nvim --headless +GoUpdateBinaries +qall
}

install_misc_tools() {
  go_get "github.com/onsi/gomega"
  go_get "github.com/onsi/ginkgo/ginkgo"
  go_get "github.com/maxbrunsfeld/counterfeiter"
  go_get "github.com/masters-of-cats/concourse-flake-hunter"
}

go_get() {
  /usr/local/go/bin/go get -u "$1"
}

compile_authorized_keys() {
  local authorized_keys keys key
  authorized_keys="$HOME/.ssh/authorized_keys"

  while read -r gh_name; do 
    key=$(curl -sL "https://api.github.com/users/$gh_name/keys" | jq -r ".[0].key")
    echo "$key $gh_name" >> "$HOME/.ssh/authorized_keys"
  done < "$HOME/workspace/eirini-home/team-github-ids"

  # remove duplicate keys
  keys=$(cat "$authorized_keys")
  echo "$keys" | sort | uniq > "$authorized_keys"
}

init_pass_store() {
  mkdir -p "$HOME/.password-store"
  ln -s "$HOME/workspace/eirini-private-config/pass/eirini" "$HOME/.password-store/"
  pass init "$(gpg --list-secret-keys | grep -o --color=never "[^<]\+@[^>]\+")"
}

install_pure_zsh_theme() {
  mkdir -p "$HOME/.zsh"
  git_clone "https://github.com/sindresorhus/pure.git" "$HOME/.zsh/pure"
  pushd "$HOME/.zsh/pure"
    git pull -r
  popd
}

switch_to_zsh() {
  sudo chsh -s /bin/zsh vagrant
}

main
