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
  add_sshd_config
  setup_locale
  install_packages
  install_snaps
  install_kubectl
  install_nodejs
  install_nvim
  install_npm_packages
  install_gcloud_cli
  install_golang
  install_cf_cli
  install_misc_tools
  install_carvel_tools
  install_delta
  install_github_cli
  install_helm3
  install_vault
}

disable_ipv6() {
  echo ">>> Disabling IPv6"
  sysctl -w net.ipv6.conf.all.disable_ipv6=1
  sysctl -w net.ipv6.conf.default.disable_ipv6=1
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

add_sshd_config() {
  echo "StreamLocalBindUnlink yes" >/etc/ssh/sshd_config.d/streamlocalbindunlink.conf
  systemctl restart ssh.service
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
    bison \
    build-essential \
    ca-certificates \
    cmake \
    cowsay \
    curl \
    direnv \
    exuberant-ctags \
    fd-find \
    fortune \
    fuse \
    g++ \
    git \
    gnupg-agent \
    iputils-ping \
    jq \
    lastpass-cli \
    libbtrfs-dev \
    libdb-dev \
    libdevmapper-dev \
    libevent-dev \
    libffi-dev \
    libgdbm-dev \
    libgdbm6 \
    libmysqlclient-dev \
    libncurses5-dev \
    libpq-dev \
    libreadline-dev \
    libreadline6-dev \
    libssl-dev \
    libtool \
    libtool-bin \
    libyaml-dev \
    net-tools \
    netcat-openbsd \
    ntp \
    openssh-server \
    pass \
    pkg-config \
    postgresql \
    postgresql-contrib \
    python3 \
    python3-dev \
    python3-pip \
    python3-venv \
    ripgrep \
    ruby-dev \
    rubygems \
    socat \
    software-properties-common \
    stow \
    tig \
    tmux \
    trash-cli \
    unzip \
    wget \
    xsel \
    zlib1g-dev \
    zsh
}

install_snaps() {
  echo ">>> Installing the Snap packages"
  snap install shfmt
  snap install lolcat
  snap install shellcheck --edge
}

install_kubectl() {
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  rm -f kubectl

  curl -sL https://github.com/vmware-tanzu/buildkit-cli-for-kubectl/releases/download/v0.1.5/linux-v0.1.5.tgz |
    tar -C /usr/local/bin -xzf -
}

install_golang() {
  echo ">>> Installing Golang"
  rm -rf /usr/local/go
  mkdir -p /usr/local/go
  curl -sL "https://dl.google.com/go/go1.18.linux-amd64.tar.gz" | tar xz -C "/usr/local"
}

install_nodejs() {
  echo ">>> Installing NodeJS"
  curl -sL https://deb.nodesource.com/setup_14.x | bash -
  apt-get -y install nodejs
}

install_nvim() {
  echo ">>> Installing NeoVim"
  if grep -q '^deb http://ppa.launchpad.net/neovim-ppa/stable/ubuntu' /etc/apt/sources.list.d/*.list; then
    add-apt-repository --remove ppa:neovim-ppa/stable -y
    apt-get remove -y neovim
  fi

  url="$(curl -s https://api.github.com/repos/neovim/neovim/releases/tags/v0.7.0 | jq -r '.assets[] | select(.name == "nvim.appimage") | .browser_download_url')"

  curl -sL "$url" --output /tmp/nvim
  chmod +x /tmp/nvim
  mv /tmp/nvim /usr/bin/
}

install_gcloud_cli() {
  echo ">>> Installing the Google Cloud CLI"
  echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee /etc/apt/sources.list.d/google-cloud-sdk.list
  curl -sL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
  apt-get update
  apt-get -y install google-cloud-sdk
}

install_cf_cli() {
  echo ">>> Installing the Cloud Foundry CLI"
  wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | apt-key add -
  echo "deb https://packages.cloudfoundry.org/debian stable main" | tee /etc/apt/sources.list.d/cloudfoundry-cli.list
  apt-get update
  apt-get -y remove cf7-cli
  apt-get -y install cf8-cli
}

install_vault() {
  curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
  apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
  apt-get update
  apt-get -y install vault
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

  echo ">>> Installing git-duet"
  curl -sL "https://github.com/git-duet/git-duet/releases/download/0.7.0/linux_amd64.tar.gz" | tar xvz -C /usr/bin

  echo ">>> Installing terraform"
  curl -sL "https://releases.hashicorp.com/terraform/0.15.4/terraform_0.15.4_linux_amd64.zip" -o /tmp/terraform.zip
  unzip -ou /tmp/terraform.zip -d /usr/bin
  rm /tmp/terraform.zip

  echo ">>> Installing bosh"
  curl -sL "https://github.com/cloudfoundry/bosh-cli/releases/download/v6.4.4/bosh-cli-6.4.4-linux-amd64" -o /usr/bin/bosh && chmod +x /usr/bin/bosh

  echo ">>> Installing skaffold"
  curl -sLo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 && install skaffold /usr/local/bin/ && rm -f skaffold

  echo ">>> Installing yq"
  curl -sLo yq https://github.com/mikefarah/yq/releases/download/v4.24.5/yq_linux_amd64 && install yq /usr/local/bin/ && rm -f yq
}

install_carvel_tools() {
  echo ">>> Installing the carvel tools"
  curl -sL https://carvel.dev/install.sh | bash

  echo ">>> Installing pack"
  curl -sSL "https://github.com/buildpacks/pack/releases/download/v0.24.0/pack-v0.24.0-linux.tgz" | tar -C /usr/local/bin/ --no-same-owner -xzv pack
}

install_npm_packages() {
  echo ">>> Installing npm packages"
  npm install -g bash-language-server tldr
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
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
  apt update
  apt install gh
}

install_helm3() {
  echo ">>> Installing Helm3"
  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 &&
    chmod 700 get_helm.sh &&
    ./get_helm.sh &&
    rm -f ./get_helm.sh
}

main $@
