# eirini-station

Common pairing environment for the Eirini Project.

# Installation

## Prerequisites

In order to run the eirini-station VM you need to have the following tools installed.

### VirtualBox

```
brew cask install virtualbox
```

Note: VirtualBox will try to install a kernel extension so you will have to go to `Security & Privacy -> General` and allow it to do so.

### Vagrant

```
brew cask install vagrant
```

### Misc tools

While the idea of the eirini-station VM is to provision the tools you will need for the daily work on Eirini there are some tools that you need
to install on the host before you run the provision script:

```
brew install gnupg
brew cask install ngrok
```

You will also need to set your ngrok authentication token:

```
ngrok authtoken <your-token>
```

Visit [ngrok.com](ngrok.com) to see your token or create an account if you don't have one. 

### Environment variables

Our `Vagrantfile` requires the following environment variables to be defined:

* `EIRINI_STATION_MEMORY`: the amount of memory to reserve for the VM, in KB.
* `EIRINI_STATION_CPUS`: the number of CPUs the VM can use. This can safely be the total number of cores on your machine.

Unfortunately these variables are needed for _every_ `vagrant` invocation (including `vagrant ssh`), so it's recommended to add them to your shell config.

## Provisioning the VM

First you'll need to install the `vagrant-vbguest` plugin, which takes care of installing and upgrading the VirtualBox guest additions on the VM:

```
vagrant plugin install vagrant-vbguest
```

If the above command takes too long and fails with an error like this one: `timed out (https://gems.hashicorp.com/specs.4.8.gz)` you probably need to turn ipv6 off by running `networksetup -setv6off Wi-Fi` and try again. To turn it back on you run `networksetup -setv6automatic Wi-Fi`.

Make sure your GitHub SSH key is loaded. Even if you are using a key from your `~/.ssh` dir you still need to load it into the SSH agent:

```
ssh-add ~/.ssh/id_rsa
```

Finally you are ready to spin up the VM:

```
vagrant up
```

# Usage

In order to start pairing you need to ssh to the eirini-station by running:

```
vagrant ssh
```

Then you can setup an ngrok tunnel. There are alreay aliases to aid you in the process:

1. `nginit`: starts an ngrok tunnel in a side tmux session called `ngrok`
1. `lsgrok`: prints an SSH command to connect to your VM, send this to your pair!
1. `pmux`: starts a tmux session called `pairing`
1. `pattach`: attaches to the `pairing` tmux session
