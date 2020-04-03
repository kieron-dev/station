#!/bin/bash
set -euo pipefail

main() {
  install_ohmyzsh
  install_vim_plug
  install_vim_extensions
  clone_git_repos
  configure_dotfiles
  install_vim_plugins
  install_misc_tools
  compile_authorized_keys
  switch_to_zsh
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
    git_clone git@github.com:cloudfoundry-incubator/eirini-ci.git
    git_clone git@github.com:cloudfoundry-incubator/eirini-release.git
    git_clone git@github.com:cloudfoundry-incubator/eirini-staging.git
    git_clone git@github.com:cloudfoundry-incubator/eirini.git
    git_clone git@github.com:cloudfoundry/eirini-private-config.git
    git_clone git@github.com:eirini-forks/eirini-home.git
    git_clone git@github.com:eirini-forks/eirini-station.git
  popd
}

git_clone() {
  local url path
  url=$1
  path=$(echo "$url" | sed 's/.git//g' | cut -d / -f 2)

  if [ -d "$HOME/workspace/$path" ]; then
    echo "Repository $path already exists. Skipping git clone..."
    return
  fi

  git clone "$url"
}

configure_dotfiles() {
  pushd "$HOME/workspace/eirini-home"
    git checkout vagrant
    ./install.sh
  popd
}

install_vim_plugins() {
  nvim --headless +PlugInstall +PlugUpdate +UpdateRemotePlugins +qall
  PATH="$PATH:/usr/local/go/bin" nvim --headless +GoUpdateBinaries +qall
}

install_misc_tools() {
  go_get github.com/onsi/gomega
  go_get github.com/onsi/ginkgo/ginkgo
  go_get github.com/maxbrunsfeld/counterfeiter
  go_get github.com/masters-of-cats/concourse-flake-hunter
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

switch_to_zsh() {
  sudo chsh -s /bin/zsh vagrant
}

main
