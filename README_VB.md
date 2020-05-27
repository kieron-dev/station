# eirini-station - Virtualbox

## Prerequisites

* All the [common prerequisites](./README.md)
* Install Virtualbox:
  ```
  brew cask install virtualbox
  ```
* Install ngrok and set up your authentication token:
  ```
  brew cask install ngrok
  ngrok authtoken <your-token>
  ```
  Visit [ngrok.com](ngrok.com) to see your token or create an account if you don't have one.
* Set up the necessary environment variables:
  - `EIRINI_STATION_MEMORY`: the amount of memory to reserve for the VM, in KB.
  - `EIRINI_STATION_CPUS`: the number of CPUs the VM can use. This can safely be the total number of cores on your machine.
  If you do not specify them defaults will be applied which may or may not be adequate for your host. Please refer to the `Vagrantfile` for details.
* Install the `vagrant-vbguest` and `vagrant-disksize` plugins:
  ```
  vagrant plugin install vagrant-vbguest
  vagrant plugin install vagrant-disksize
  ```
  If the above command takes too long and fails with an error like this one:
  `timed out (https://gems.hashicorp.com/specs.4.8.gz)` you probably need to
  turn ipv6 off by running `networksetup -setv6off Wi-Fi` and try again. To
  turn it back on you run `networksetup -setv6automatic Wi-Fi`.

## Usage

Start the VM:

```
vagrant up
```

SSH into the VM:

```
vagrant ssh
```

Once on the VM, you'll need to start an ngrok tunnel to allow your pair to SSH on the VM:

```
nginit
```

This will start an ngrok tunnel in a side tmux session called `ngrok`

Then print the SSH command needed to connect to your VM and send it to your pair!

```
lsgrok
```

You can now start your pairing session:

```
pmux
```

You pair can then join the session:

```
pattach
```
