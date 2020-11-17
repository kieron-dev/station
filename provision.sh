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
  add_swap
  setup_locale
  install_packages
  install_snaps
  install_nodejs
  install_telepresence
  install_nvim
  install_npm_packages
  install_gcloud_cli
  install_golang
  install_cf_cli
  install_misc_tools
  install_k14s_tools
  install_delta
  install_github_cli
}

disable_ipv6() {
  echo ">>> Disabling IPv6"
  sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
  sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
}

add_swap() {
  local swapsize=4096

  if ! grep -q "swapfile" /etc/fstab; then
    echo 'swapfile not found. Adding swapfile.'
    fallocate -l ${swapsize}M /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap defaults 0 0' >>/etc/fstab
  else
    echo 'swapfile found. No changes made.'
  fi
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
    cowsay \
    ctags \
    curl \
    direnv \
    fortune \
    g++ \
    git \
    gnupg-agent \
    iputils-ping \
    jq \
    lastpass-cli \
    libbtrfs-dev \
    libdevmapper-dev \
    libevent-dev \
    libncurses5-dev \
    libreadline-dev \
    libssl-dev \
    libtool \
    libtool-bin \
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
    tig \
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
  snap install lolcat
}

install_golang() {
  echo ">>> Installing Golang"
  mkdir -p /usr/local/go
  curl -sL "https://dl.google.com/go/go1.15.3.linux-amd64.tar.gz" | tar xz -C "/usr/local"
}

install_nodejs() {
  echo ">>> Installing NodeJS"
  curl -sL https://deb.nodesource.com/setup_14.x | bash -
  apt-get -y install nodejs
}

install_telepresence() {
  echo ">>> Installing Telepresence"
  curl -s https://packagecloud.io/install/repositories/datawireio/telepresence/script.deb.sh | bash
  apt-get -y install telepresence
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

  echo ">>> Installing v6"
  local tmpdir="$(mktemp -d)"
  trap "rm -rf $tmpdir" EXIT
  wget -q -O - "https://packages.cloudfoundry.org/stable?release=linux64-binary&version=6.49.0" | tar xz -C "$tmpdir" cf
  mv "$tmpdir/cf" "/usr/bin/cf6"

  echo ">>> Installing v7"
  wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | sudo apt-key add -
  echo "deb https://packages.cloudfoundry.org/debian stable main" | sudo tee /etc/apt/sources.list.d/cloudfoundry-cli.list
  apt-get update
  apt-get -y install cf7-cli
}

install_misc_tools() {
  echo ">>> Installing ngrok"
  curl -sL "https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.tgz" | tar xz -C /usr/bin

  echo ">>> Installing goml"
  curl -sL "https://github.com/JulzDiverse/goml/releases/download/v0.7.0/goml-linux-amd64" -o /usr/bin/goml && chmod +x /usr/bin/goml

  echo ">>> Installing spruce"
  curl -sL https://github.com/geofffranks/spruce/releases/download/v1.25.3/spruce-linux-amd64 -o /usr/bin/spruce && chmod +x /usr/bin/spruce

  echo ">>> Installing aviator"
  curl -sL "https://github.com/JulzDiverse/aviator/releases/download/v1.6.0/aviator-linux-amd64" -o /usr/bin/aviator && chmod +x /usr/bin/aviator

  echo ">>> Installing dhall-json"
  curl -sL "https://github.com/dhall-lang/dhall-haskell/releases/download/1.30.0/dhall-json-1.6.2-x86_64-linux.tar.bz2" | tar xvj -C /usr

  echo ">>> Installing dhall-lsp-server"
  curl -sL "https://github.com/dhall-lang/dhall-haskell/releases/download/1.30.0/dhall-lsp-server-1.0.5-x86_64-linux.tar.bz2" | tar xvj -C /usr

  echo ">>> Installing git-duet"
  curl -sL "https://github.com/git-duet/git-duet/releases/download/0.7.0/linux_amd64.tar.gz" | tar xvz -C /usr/bin

  echo ">>> Installing terraform"
  curl -sL "https://releases.hashicorp.com/terraform/0.12.26/terraform_0.12.26_linux_amd64.zip" -o /tmp/terraform.zip
  unzip -u /tmp/terraform.zip -d /usr/bin
  rm /tmp/terraform.zip

  echo ">>> Installing bosh"
  curl -sL "https://github.com/cloudfoundry/bosh-cli/releases/download/v6.2.1/bosh-cli-6.2.1-linux-amd64" -o /usr/bin/bosh && chmod +x /usr/bin/bosh

  echo ">>> Installing skaffold"
  curl -sLo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 && sudo install skaffold /usr/local/bin/ && rm -f skaffold

  echo ">>> Installing yq"
  curl -sLo yq https://github.com/mikefarah/yq/releases/download/3.4.1/yq_linux_amd64 && sudo install yq /usr/local/bin/ && rm -f yq
}

install_k14s_tools() {
  echo ">>> Installing the k14s tools"
  curl -sL https://k14s.io/install.sh | bash

  echo ">>> Installing pack"
  curl -sSL "https://github.com/buildpacks/pack/releases/download/v0.14.1/pack-v0.14.1-linux.tgz" | sudo tar -C /usr/local/bin/ --no-same-owner -xzv pack
}

install_npm_packages() {
  echo ">>> Installing npm packages"
  npm install -g bash-language-server
}

install_delta() {
  echo ">>> Installing delta"
  set -x
  curl -sL https://github.com/dandavison/delta/releases/download/0.1.1/delta-0.1.1-x86_64-unknown-linux-musl.tar.gz -o /tmp/delta.tar.gz
  tar xzvf /tmp/delta.tar.gz
  mv delta-0.1.1-x86_64-unknown-linux-musl/delta /usr/bin
  rm -fr delta-0.1.1-x86_64-unknown-linux-musl /tmp/delta.tar.gz
  set +x
}

install_github_cli() {
  echo ">>> Installing Github CLI"
  sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key C99B11DEB97541F0
  sudo apt-add-repository https://cli.github.com/packages
  sudo apt update
  sudo apt install gh
}

main $@
