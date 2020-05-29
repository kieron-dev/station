#!/bin/bash
set -euo pipefail

readonly USAGE="Usage: provision.sh [-l | -c <command_name>]"

main() {
  if [[ $EUID -ne 0 ]]; then
    echo "Script must be run as root."
    exit 1
  fi

  while getopts ":lch" opt; do
    case ${opt} in
      l)
        declare -F | awk '{ print $3 }' | grep -v main
        exit 0
        ;;
      c)
        shift $((OPTIND - 1))
        for command in $@; do
          $command
        done
        exit $?
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
  disable_ipv6
  setup_locale
  install_packages
  install_snaps
  install_nodejs
  install_nvim
  install_npm_packages
  install_gcloud_cli
  install_golang
  install_cf_cli
  install_misc_tools
  install_k14s_tools
}

disable_ipv6() {
  echo ">>> Disabling IPv6"
  sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
  sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
}

setup_locale() {
  echo ">>> Setting up the en_US locale"
  apt-get -y install locales
  locale-gen en_US.UTF-8
  update-locale LANG=en_US.UTF-8
}

install_packages() {
  echo ">>> Installing the APT packages"
  apt-get update
  apt-get -y install \
    apt-transport-https \
    autoconf \
    automake \
    build-essential \
    ca-certificates \
    cmake \
    ctags \
    curl \
    direnv \
    g++ \
    git \
    gnupg-agent \
    iputils-ping \
    jq \
    lastpass-cli \
    libevent-dev \
    libncurses5-dev \
    libreadline-dev \
    libtool \
    libtool-bin \
    libssl-dev \
    net-tools \
    netcat-openbsd \
    ntp \
    openssh-server \
    pass \
    pkg-config \
    python3 \
    python3-dev \
    python3-pip \
    python3-venv \
    ripgrep \
    ruby-dev \
    rubygems \
    shellcheck \
    socat \
    software-properties-common \
    stow \
    tmux \
    trash-cli \
    unzip \
    wget \
    xsel \
    zsh
}

install_snaps() {
  echo ">>> Installing the Snap packages"
  snap install shfmt
}

install_golang() {
  echo ">>> Installing Golang"
  mkdir -p /usr/local/go
  curl -sL "https://dl.google.com/go/go1.14.linux-amd64.tar.gz" | tar xz -C "/usr/local"
}

install_nodejs() {
  echo ">>> Installing NodeJS"
  curl -sL https://deb.nodesource.com/setup_13.x | bash -
  apt-get -y install nodejs
}

install_nvim() {
  echo ">>> Installing NeoVim"
  add-apt-repository -y ppa:neovim-ppa/unstable
  apt-get update
  apt-get -y install neovim
}

install_gcloud_cli() {
  echo ">>> Installing the Google Cloud CLI"
  echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list
  curl -sL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
  apt-get update
  apt-get -y install google-cloud-sdk
}

install_cf_cli() {
  echo ">>> Installing the Cloud Foundry CLI"
  wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | sudo apt-key add -
  echo "deb https://packages.cloudfoundry.org/debian stable main" | sudo tee /etc/apt/sources.list.d/cloudfoundry-cli.list
  apt-get update
  apt-get -y install cf-cli=6.49.0
  sudo tee /etc/apt/preferences.d/cf-cli >/dev/null <<EOF
Package: cf-cli
Pin: version 6.49*
Pin-Priority: 1000
EOF
}

install_misc_tools() {
  echo ">>> Installing ngrok"
  curl -sL "https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.tgz" | tar xz -C /usr/bin

  echo ">>> Installing goml"
  curl -sL "https://github.com/JulzDiverse/goml/releases/download/v0.7.0/goml-linux-amd64" -o /usr/bin/goml && chmod +x /usr/bin/goml

  echo ">>> Installing aviator"
  curl -sL "https://github.com/JulzDiverse/aviator/releases/download/v1.6.0/aviator-linux-amd64" -o /usr/bin/aviator && chmod +x /usr/bin/aviator

  echo ">>> Installing fly"
  curl -sL "https://jetson.eirini.cf-app.com/api/v1/cli?arch=amd64&platform=linux" -o /usr/bin/fly && chmod +x /usr/bin/fly

  echo ">>> Installing dhall-json"
  curl -sL "https://github.com/dhall-lang/dhall-haskell/releases/download/1.30.0/dhall-json-1.6.2-x86_64-linux.tar.bz2" | tar xvj -C /usr

  echo ">>> Installing dhall-lsp-server"
  curl -sL "https://github.com/dhall-lang/dhall-haskell/releases/download/1.30.0/dhall-lsp-server-1.0.5-x86_64-linux.tar.bz2" | tar xvj -C /usr

  echo ">>> Installing git-duet"
  curl -sL "https://github.com/git-duet/git-duet/releases/download/0.7.0/linux_amd64.tar.gz" | tar xvz -C /usr/bin
}

install_k14s_tools() {
  echo ">>> Installing the k14s tools"
  curl -sL https://k14s.io/install.sh | bash
}

install_npm_packages() {
  echo ">>> Installing npm packages"
  npm install -g bash-language-server diff-so-fancy
}

main $@
