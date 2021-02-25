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

## Forwarding your GPG agent to a remote station

When you create your station your GPG key will not be copied to it for security reasons. Instead, your gpg-agent socket
will be forwarded to the remote station so that the gpg program can access it. If you are the owner of the station you
do not have to do anything special, but if you are joining a teammate's session and want to be able to use your GPG key
there you need to do the socket forwarding yourself. To make this easy there is a tool called `pair-connect`. You can
install it by running the following command:

```
sudo bash -c " curl -o /usr/local/bin/pair-connect https://raw.githubusercontent.com/eirini-forks/eirini-station/master/scripts/pair-connect && chmod +x /usr/local/bin/pair-connect"
```

Then in order to connect you need to run

```
pair-connect -a user@hostname
```

In order to find out the address of the remote session you want to join, ask your pair to run `pssh` on the station owned by them.

### Switching between the GPG sockets of the station owner and a guest

Since both the station owner and any pair who connected using `pair-connect` have their GPG agent sockets forwarded there needs to be
a way to switch between all available sockets. The sockets can be found at `~/.gnupg` on the station. They are generally in the format
`S.gpg-agent-<username>`, where `<username>` is the subject before the `@` sign in the ssh key loaded in the ssh-aget. You can view yours
by running the following command on your host machine:

```
ssh-add -L
```` 

In order to switch to a particular user's GPG agent socket you need to run `fix-gpg <username>` command on the station. If you are not sure what 
is your user you can run `use-gpg` which will interactively prompt you to select your user from a list of all users who forwarded 
their gpg agent sockets

You can check which GPG agent socket is currently in use by running `who-gpg` on the station.
