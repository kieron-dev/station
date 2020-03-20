#!/bin/bash
set -euo pipefail

main() {
  install_ohmyzsh
  install_vim_plug
  clone_git_repos
  configure_dotfiles
  install_misc_tools
  compile_authorized_keys
}

install_ohmyzsh() {
  [ ! -d "$HOME/.oh-my-zsh" ] && sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  # Delete default .zshrc to avoid stow conflicts
  rm -f ~/.zshrc
}

install_vim_plug() {
  curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  nvim +'PlugInstall' +qa
}

clone_git_repos() {
  mkdir ~/workspace
  pushd ~/workspace
    git clone git@github.com:eirini-forks/eirini-ci.git
    git clone git@github.com:eirini-forks/eirini-home.git
    git clone git@github.com:eirini-forks/eirini-private-config.git
    git clone git@github.com:eirini-forks/eirini-release.git
    git clone git@github.com:eirini-forks/eirini-staging.git
    git clone git@github.com:eirini-forks/eirini-station.git
    git clone git@github.com:eirini-forks/eirini.git
  popd
}

configure_dotfiles() {
  pushd ~/workspace/eirini-home
    git checkout docker
    ./install.sh
  popd
}

install_misc_tools() {
  go get -u github.com/onsi/gomega
  go get -u github.com/onsi/ginkgo/ginkgo
  go get -u github.com/maxbrunsfeld/counterfeiter
  go get -u github.com/masters-of-cats/concourse-flake-hunter
}

compile_authorized_keys() {
  rm -f ~/.ssh/authorized_keys
  while read -r gh_name; do 
    key=$(curl -sL "https://api.github.com/users/$gh_name/keys" | jq -r ".[0].key")
    echo "$key $gh_name" >> ~/.ssh/authorized_keys
  done < ~/workspace/eirini-home/team-github-ids
}

main
