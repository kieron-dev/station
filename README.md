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
can just `vagrant ssh` and your socket will be automatically forwarded, but if you are joining a teammate's session 
you should pass some extra args to `ssh` in order to do the forwarding. To make this easy there are some aliases defined
in the home config. The host can use those to generate the connection command and send it to you. Here is how they work:

- on a gloud machine the owner should run `pssh`
- on a local virtualbox machine the owner should run `lsgrok`

Running the oneliner that the station owner sent you will log you onto the machine with your gpg agent socket forwarded.

### Switching between the GPG sockets of the station owner and a guest

Since both the station owner and their pair have their GPG agent sockets forwarded, there needs to be
a way to switch between the two sockets. This can be done using the `fix-gpg` alias defined in `eirini-home`. If you are
the guest and you want to use gpg while your host is away, you can run `fix-gpg guest`. If you are the host and want to
reacquire control, you can run `fix-gpg` with no args.

You can check which socket is active at any time by running `who-gpg`.
