# eirini-station - Google Cloud

## Prerequisites

* All the [common prerequisites](./README.md)
* Install the `vagrant-google` plugin:
  ```
  vagrant plugin install vagrant-google
  ```
* Add the SSH key you're going to use to GCE Metadata in _Compute -> Compute
  Engine -> Metadata_ section of the console, _SSH Keys_ tab.
  This has to be the same key you have loaded in your local SSH agent!
* Retrieve the Eirini service account JSON key and save it somewhere convenient
  on your machine. You could ask a team member to send it securely to you, or
  you can get it from our `pass` store, which lives in
  [`eirini-private-config`](https://github.com/cloudfoundry/eirini-private-config#sensitive-passwords).
  The name of the key is `eirini/gcp-eirini-station-json-key`.
* Set up the necessary environment variables:
  - `EIRINI_STATION_USERNAME`: the username associated to your key in the _Metadata_
  - `EIRINI_STATION_GCP_JSON_KEY_PATH`: the path to your copy of the JSON key for the eirini GCP service account

## Usage

Start the VM:

```
vagrant up --provider=google
```

SSH into the VM:

```
vagrant ssh
```

Print the command to ssh onto the VM and send it to your pair:

```
pssh
```

You can now start your pairing session:

```
pmux
```

You pair can then join the session:

```
pattach
```

## Station script

Alternatively you can put [this script](https://raw.githubusercontent.com/eirini-forks/eirini-home/master/util/bin/station) somewhere on your path. It is a tiny vagrant wrapper that exports the necessary env vars for you and delegates to vagrant.
You can easily provision the vm by running `station up` or `station provision` from any directory.
Logging onto the vm is as easy as `station ssh`
