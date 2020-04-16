#!/bin/bash
set -euo pipefail

main() {
  apt-get update

  disable_ipv6
  setup_locale
  install_packages
  install_nodejs
  install_nvim
  install_gcloud_cli
  install_golang
  install_cf_cli
  install_misc_tools
  build_diff_highlight
  install_k14s_tools
}

disable_ipv6() {
  sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
  sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
}

setup_locale() {
  apt-get -y install locales
  locale-gen en_US.UTF-8
  update-locale LANG=en_US.UTF-8
}

install_packages() {
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
    unzip \
    wget \
    xsel \
    zsh
}

install_golang() {
  mkdir -p /usr/local/go
  curl -sL "https://dl.google.com/go/go1.14.linux-amd64.tar.gz" | tar xz -C "/usr/local"
}

install_nodejs() {
  curl -sL https://deb.nodesource.com/setup_13.x | bash -
  apt-get -y install nodejs
}

install_nvim() {
  add-apt-repository ppa:neovim-ppa/unstable
  apt-get update
  apt-get -y install neovim
}

install_gcloud_cli() {
  # Add the Cloud SDK distribution URI as a package source
  echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list
  # Import the Google Cloud Platform public key
  curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
  # Update the package list and install the Cloud SDK
  apt-get update
  apt-get -y install google-cloud-sdk
}

install_cf_cli() {
  # ...first add the Cloud Foundry Foundation public key and package repository to your system
  wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | sudo apt-key add -
  echo "deb https://packages.cloudfoundry.org/debian stable main" | sudo tee /etc/apt/sources.list.d/cloudfoundry-cli.list
  # ...then, update your local package index, then finally install the cf CLI
  apt-get update
  apt-get -y install cf-cli=6.49.0
}

install_misc_tools() {
  curl -sL "https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.tgz" | tar xz -C /usr/bin
  curl -sL "https://github.com/JulzDiverse/goml/releases/download/v0.7.0/goml-linux-amd64" -o /usr/bin/goml && chmod +x /usr/bin/goml
  curl -sL "https://github.com/JulzDiverse/aviator/releases/download/v1.6.0/aviator-linux-amd64" -o /usr/bin/aviator && chmod +x /usr/bin/aviator
  curl -sL "https://jetson.eirini.cf-app.com/api/v1/cli?arch=amd64&platform=linux" -o /usr/bin/fly && chmod +x /usr/bin/fly
  curl -sL "https://github.com/dhall-lang/dhall-haskell/releases/download/1.30.0/dhall-json-1.6.2-x86_64-linux.tar.bz2" | tar xvj -C /usr
  curl -sL "https://github.com/dhall-lang/dhall-haskell/releases/download/1.30.0/dhall-lsp-server-1.0.5-x86_64-linux.tar.bz2" | tar xvj -C /usr
  curl -sL "https://github.com/git-duet/git-duet/releases/download/0.7.0/linux_amd64.tar.gz" | tar xvz -C /usr/bin
}

build_diff_highlight() {
  pushd /usr/share/doc/git/contrib/diff-highlight
    make
    chmod a+x diff-highlight
  popd
}

install_k14s_tools() {
  curl -L https://k14s.io/install.sh | bash
}

main
