# Eirini GCP station

This is a set of scripts which makes it easier to create development stations
on GCP. The scripts only use the [`gcloud`
CLI](https://cloud.google.com/sdk/gcloud) and don't automate provisioning.

## Dependencies

The scripts only need the [`gcloud` CLI](https://cloud.google.com/sdk/gcloud)
and the `$EIRINI_STATION_USERNAME` environment variable set.

## Usage

To get a working station:

```
$ ./auth.sh
$ ./create.sh
$ ./ssh.sh
```

Once on the machine, you'll have to provision it manually:

```
$ mkdir workspace
$ git clone git@github.com:eirini-forks/eirini-station.git workspace/eirini-station
$ sudo workspace/eirini-station/provision.sh
$ workspace/eirini-station/provision-user.sh
```

To stop the machine:

```
./stop.sh
```

To start the machine back:

```
./start.sh
```

To destroy the machine:

```
./destroy.sh
```
