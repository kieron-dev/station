# eirini-station

Common pairing environment for the Eirini Project. You can set up a development VM locally on [Virtualbox](./README_VB.md) or on the cloud using [GCP](./README_GCP.md).

## Common prerequisites

In order to run the eirini-station VM you need to:

- Install Vagrant:
  ```
  brew cask install vagrant
  ```
- Install GnuPG:
  ```
  brew install gnupg
  ```
- Set up your GPG store with your private key and everyone's public keys (see
  [eirini-private-config](https://github.com/cloudfoundry/eirini-private-config#sensitive-passwords)
  for more details)
- Load your SSH key in the ssh agent (even if you are using a key from your `~/.ssh` dir you still need to load it):
  ```
  ssh-add ~/.ssh/id_rsa
  ```

## Forwarding your GPG agent to a remote stastion

When you crate your station your GPG key will not be copied to it for security reasons. Instead, your gpg-agent socket
will be forwarder to the remote station so that the gpg program can access it. If you are the owner of the station you
do not have to do anything special, but if you are joining a teammate's session and want to be able to use your GPG key
there you need to do the socket forwarding yourself. To make this easy there is a tool calle `pair-connect`. You can
install it by running the following command:

```
sudo bash -c " curl -o /usr/local/bin/pair-connect https://raw.githubusercontent.com/eirini-forks/eirini-station/master/scripts/pair-connect && chmod +x /usr/local/bin/pair-connect"
```

Then in order to connect you need to run

```
pair-connect -a user@hostname
```

In order to find out the address of the remote session you want to join, ask your pair to run `pssh` on the station owned by them.
