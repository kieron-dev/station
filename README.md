# eirini-station
Common pairing environment for the Eirini Project

# Installation

## Prerequisites

In order to run the eirini-station VM you need to have the following tools installed

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



## Provisioning the VM

From the root of this repository execute the following commands

```
vagrant plugin install vagrant-vbguest
```

If the above command takes too long and fails with an error like this one: `timed out (https://gems.hashicorp.com/specs.4.8.gz)` you probably need to turn ipv6 off by running `networksetup -setv6off Wi-Fi` and try again. To turn it back on you run `networksetup -setv6automatic Wi-Fi`

Make sure your github ssh key is loaded. Even if you are using a key from your `~/.ssh` dir you still need to load it into the ssh agent:

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
1. Run `pmux`. This will open a tmux session called `pairing`
1. Run `ngrok authtoken <your-token>`. Visit [ngrok.com](ngrok.com) to see your token or create an account if you don't have one. 
1. Run `nginit`. This will setup the ngrok tunnel in a side tmux session called `ngrok`
1. Run `lsgrok` and send the output to your pair. This is the command that will let them attach to your session.
