# AutoPiBakery

A Docker project which aims to make creating a Raspberry Pi project simple. When working with a Raspberry Pi project, one of the challenges is locating the base image, configuring it on the device, and installing your project code. This project helps mix these ingredients together in one single command.

The motivation behind this project is to take some of the repetition out of the process of making a Raspberry Pi project. Typically as engineers we are familiar with automating many stages of development. Creating the artifact to deploy to the Raspberry Pi should be no different in this regard.

# Acknowledgement

All of this would not be possible without the great work of MrSimonEmms and the [PiOven](https://github.com/PiOven/builder) project.

# Overview

At a high level, the Docker command for this project will start with a stock Raspbian image. Then it will apply configurations to the image such as SSH and WiFi settings. Next the command will copy in any project files you want to use for the project before finally baking the entire image. This can then be flashed on to the Raspberry Pi as a single artifact which is ready to use.

# Folder Structure

In order to use this Docker command you will want to have two folders in a local directory.

* `input`: will contain the project files you would like included in the Raspberry Pi image.
* `output`: will be the location where the image is generated to and includes the generated SSH keys that can be used to access the system.

# Input Files

These are the project files and essentially needs to consist of everything your project needs to run on the Raspberry Pi. In the case of a Raspberry Pi Zero W this will be an ARMv6 CPU and so all binaries need to be compatible with this target system.

There is a single entrypoint which must be included. This is the `start.sh` script. This script will need to both install any dependencies have and also launch the application. Importantly, the script must not exit execution, otherwise it will be restarted.

Storage space within the Raspberry Pi image is limited to a few hundred MB.

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
    -ti gencore/auto-pi-bakery-jessie:latest
```

# Contacting the Raspberry Pi
Once the Pi has been powered on, it will start its boot up sequence which will include automatic configuration of the Wireless settings (if used) and other configuration. Once it has completed this setup it will be accessible on the local network with the [standard multicast network address](https://www.raspberrypi.org/documentation/remote-access/ip-address.md):

```
$ ping raspberrypi.local
PING raspberrypi.local (192.168.1.84): 56 data bytes
64 bytes from 192.168.1.84: icmp_seq=0 ttl=64 time=7.699 ms
64 bytes from 192.168.1.84: icmp_seq=1 ttl=64 time=7.195 ms
```

Due to the installation sequence, the Rasperry Pi will restart after it has been configured. Therefore it will be accessible on this access only for a short while. Afterwards it will no longer respond on this multicast address and instead will respond on a dynamically configured hostname.

We recommend starting a `ping` on the `raspberrypi.local` address and observing the IP address that responds.

Once you know the IP address of the system you can SSH to the system using the following:

```
ssh -i output/key user@192.168.1.84
```

## Known Error `can't set up loop`

When running this multiple times with Docker for MacOS we have observed that there will come a point where there are no more Loop devices available for the system to mount to. In this case, simply restart Docker.

```
mount: could not find any device /dev/loop#Bad address
can't set up loop
```