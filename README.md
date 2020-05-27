# eirini-station

Common pairing environment for the Eirini Project. You can set up a development VM locally on [Vitualbox](./README_VB.md) or on the cloud using [GCP](./README_GCP.md).

## Common prerequisites

In order to run the eirini-station VM you need to:

* Install Vagrant:
  ```
  brew cask install vagrant
  ```
* Install GnuPG:
  ```
  brew install gnupg
  ```
* Set up your GPG store with your private key and everyone's public keys (see
  [eirini-private-config](https://github.com/cloudfoundry/eirini-private-config#sensitive-passwords)
  for more details)
* Load your SSH key in the ssh agent (even if you are using a key from your `~/.ssh` dir you still need to load it):
  ```
  ssh-add ~/.ssh/id_rsa
  ```
