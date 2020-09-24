# AutoPiBakery

A project with the goal of a single Docker command producing a Raspberry Pi image which includes the desired project executable.

# Overview

When working on projects, as engineers we are used to being able to automate the build process to generate the final artifact of the project. If the target for the project is a Raspberry Pi based project then it is logical to automate the production of the image used to flash the Raspberry Pi.

This project attempts to automate the process of building a finished Raspberry Pi image which has the users project files included in the generated image. It builds upon the great work by MrSimonEmms and the PiOven project.

The ambition for this project is that the user provides a single Docker command which can then generate the finished Raspberry Pi image. Initial target for the project is a Raspberry Pi Zero running Raspbian Jessie. This project could be expanded to support other variants quite easily.

# Build

docker build -t auto-pi-bakery:raspbian-jessie .

# Run Examples

This example generates an image which has built in Wireless Settings. These are specified using the following environment variables:

* PI_WIFI_SSID
* PI_WIFI_PASS

The output from this command will be the finished Raspberry Pi image and so we need to provide a target folder for the output to be stored in.

```
rm -r target && mkdir target
```

```
docker run \
	--rm \
    --privileged \
    -e PI_WIFI_SSID=<wireless SSID> \
    -e PI_WIFI_PASS=<wireless Password> \
    -v $PWD/target:/target \
    -ti auto-pi-bakery:raspbian-jessie
```

*Available Space*

There appears to be 621MB of space available.

Filesystem           Size  Used Avail Use% Mounted on
overlay               32G   21G  9.4G  69% /
tmpfs                 64M     0   64M   0% /dev
tmpfs                2.0G     0  2.0G   0% /sys/fs/cgroup
shm                   64M     0   64M   0% /dev/shm
osxfs                932G  734G  184G  81% /target
/dev/vda1             32G   21G  9.4G  69% /ssh-keys
/dev/mapper/loop6p1   42M   21M   21M  51% /media/rpi_boot
/dev/mapper/loop6p2  1.6G  827M  621M  58% /media/rpi_root

*Concept*

The user places their files into a folder along with a script with a fixed name `run.sh`. This script will invoke their project. Then they invoke the Docker command with environment variables provided which will then include the project files into the build process of the Raspberry Pi image.

## Known Error

When running this multiple times with Docker for MacOS we have observed that there will come a point where there are no more Loop devices available for the system to mount to. In this case, simply restart Docker.

```
mount: could not find any device /dev/loop#Bad address
can't set up loop
```

*Source*

$ make build
make docker-run CMD="sh ./scripts/pibuilder.sh"
mkdir -p ./dist/cache
mkdir -p ./dist/ssh-keys
touch ./dist/settings.sh
docker run \
		-it \
		--privileged \
		--rm \
		-v "/Users/robert.wapshott/tmp/PiOven/builder/dist/settings.sh:/opt/pibuilder/settings.sh" \
		-v "/Users/robert.wapshott/tmp/PiOven/builder/dist/cache:/opt/pibuilder/cache" \
		-v "/Users/robert.wapshott/tmp/PiOven/builder/dist/ssh-keys:/ssh-keys" \
		-v "/Users/robert.wapshott/tmp/PiOven/builder/scripts:/opt/pibuilder/scripts" \
		-u 0 \
		riggerthegeek/pibuilder \
		sh ./scripts/pibuilder.sh