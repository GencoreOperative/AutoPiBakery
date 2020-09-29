# AutoPiBakery

A Docker project which aims to make creating a Raspberry Pi project simple. A challenge when working with a Raspberry Pi is the repeated tasks of locating an image, configuration, and installing your project code onto the Pi. This project helps mix these ingredients together in one command.

The motivation behind this project is to take some of the repetition out of the process of making a Raspberry Pi project. Typically as engineers we are familiar with automating many stages of development. Creating the artifact to deploy to the Raspberry Pi should be no different in this regard.

# Acknowledgement

All of this would not be possible without the great work of MrSimonEmms and the [PiOven](https://github.com/PiOven/builder) project.

# Overview

At a high level, the Docker command for this project will start with a stock Raspbian image. Then it will apply configurations to the image such as SSH and WiFi settings. Next the command will copy in any project files you want to use for the project before finally baking the entire image. This can then be flashed on to the Raspberry Pi as a single artifact which is ready to use.

# Folder Structure

In order to use this Docker command you will want to have two folders in a local directory.

* `input`: will contain the project files you would like included in the Raspberry Pi image. This must include a script called `start.sh` which will be the entry point for your application.
* `output`: will be the location where the image is generated to and includes the generated SSH keys that can be used to access the system.

# Input Files

These are the project files and essentially needs to be everything you need for your project. For example, if it is a Java application then you will need to include the Java Runtime as well. Because these files will be executing on the Raspberry Pi they all need to be aimed at the ARM CPU architecture.

Importantly, there needs to be a script called `start.sh`. This script will be the entry point for your project and should both install any dependencies into the Raspberry Pi and also launch the project.

`start.sh` will be called once on startup of the Raspberry Pi.

Space is limited to a few hundred MB.

# Run Examples

This example generates an image which has built in Wireless Settings. These are specified using the following environment variables:

* PI_WIFI_SSID: The SSID of your wireless network
* PI_WIFI_PASS: The plaintext password of the network

The output from this command will be the finished Raspberry Pi image and so we need to provide a target folder for the output to be stored in.

```
rm -r output && mkdir output
```

```
docker run \
	--rm \
    --privileged \
    -e PI_WIFI_SSID=<wireless SSID> \
    -e PI_WIFI_PASS=<wireless Password> \
    -v $PWD/input:/input \
    -v $PWD/output:/output \
    -ti auto-pi-bakery:raspbian-jessie
```

# Contacting the Raspberry Pi

TODO: https://www.raspberrypi.org/documentation/remote-access/ip-address.md

Once the Pi has been powered on, it will start its boot up sequence which will include automatic configuration of the Wireless settings (if used) and other configuration. Once it has completed this setup it will be accessible on the local network with the standard multicast network address:

```
$ ping raspberrypi.local
PING raspberrypi.local (192.168.1.84): 56 data bytes
64 bytes from 192.168.1.84: icmp_seq=0 ttl=64 time=7.699 ms
64 bytes from 192.168.1.84: icmp_seq=1 ttl=64 time=7.195 ms
```

DETAIL here: after the first boot, this address will no longer respond. Instead the new hostname of the system will respond. Therefore knowing the hostname of the system is important.


From here we can SSH onto the device by using the private key that was generated as part of the installation:

```
$ ssh -i output/key user@192.168.1.84
```

## Known Error

When running this multiple times with Docker for MacOS we have observed that there will come a point where there are no more Loop devices available for the system to mount to. In this case, simply restart Docker.

```
mount: could not find any device /dev/loop#Bad address
can't set up loop
```