# Overview

This file is aimed at developers looking to understand how this project works. It aims to explain how the project operates along with the specific knowledge needed to maintain the project. This project extends the functionality of [PiOven](https://github.com/PiOven/builder) developed by MrSimonEmms. Understanding how that project works will be of interest for the reader.

# Layers

The build system developed here operates on multiple levels that need to be understood in order to make changes. Understanding these levels and therefore the operations that can be performed has represented an interesting learning exercise for this project.

*Docker Build Space*
At this level we are copying files from this project into the Docker image. All scripts and patches needed are installed into the file system of the Docker container. This includes patching the original scripts provided by MrSimonEmms and copying in additional scripts.

*Docker Run Space*
At this runtime level we are executing the Docker command to generate the Raspberry Pi image. Any environment variables are accessible at this stage. The `runtime.sh` script is executed which will collect these environment variables and place them in files which will be included in the next level down. In addition, SSH keys are generated at this level and placed in the location that `pibuilder.sh` expects.

*PiBuilder.sh Run Space*
During the Docker run the patched `pibuilder.sh` script is executed which will then perform another layer of operations which can only be performed at this level. The Raspberry Pi image is sourced and mounted at this point so this is the level where we can copy files into the Raspberry Pi image.

At this stage the users `input` folder can be copied in.

*First_Run.sh Run Space*
The final run space is on the Raspberry Pi. At this stage the Pi will configure itself, and the user service will be installed which will look to run the user's scripts.

# Service Installation

This project uses [systemd](https://www.raspberrypi.org/documentation/linux/usage/systemd.md) for installation of the user's application.

We achieve this by modifying the `first_run.sh` script to install the service during initial setup. This only needs to be done once for the system so makes sense to include in the `first_run.sh` script. This script automatically deletes itself once complete leaving the installed service which will automatically load on system start.

The installed service will call the `start.sh` script. This script should execute indefinitely. If the `start.sh` script does exit, then the systemd manager will restart the service.

# Docker Run Error: `Can't set up loop`

When developing on the project we will need to iterate a number of times. We noticed that eventually there was an error around this. The cause of this is the behaviour of the loop back devices which are emulated within Docker. As the Linux container uses them and unmounts them the Docker host does not appear to unmount them. This means once all 8 are used up the Docker host needs restarting.

```
mount: could not find any device /dev/loop#Bad address
can't set up loop
```

# GNU Patch

In order to efficiently patch the original files we can use GNU Patch to apply diffs. The following sequence will download and compile the binary. This can be used on the Docker container to patch the provided scripts:

```
cd /tmp && curl -s https://ftp.gnu.org/gnu/patch/patch-2.7.tar.gz | tar xvzf - && cd /tmp/patch-2.7/ && ./configure && make && make install
```

# Notes on debugging installation

The `pibuilder.sh` script modifies the `rc.local` file to trigger the first_run.sh script. This script is configured to log the commands it is executing to the /var/log/rc.local.log file. This allows for debugging of the Raspberry Pi levels of execution and installation.

# Balena Etcher

Disable DropBox as it appears to like bothering the SDCard each time it is connected. This causes Etcher to bail repeatedly.

# Available Space

For the Raspbian Jessie image there appears to be 621MB of space available.

```
Filesystem           Size  Used Avail Use% Mounted on
overlay               32G   21G  9.4G  69% /
tmpfs                 64M     0   64M   0% /dev
tmpfs                2.0G     0  2.0G   0% /sys/fs/cgroup
shm                   64M     0   64M   0% /dev/shm
osxfs                932G  734G  184G  81% /target
/dev/vda1             32G   21G  9.4G  69% /ssh-keys
/dev/mapper/loop6p1   42M   21M   21M  51% /media/rpi_boot
/dev/mapper/loop6p2  1.6G  827M  621M  58% /media/rpi_root
```

# Package Dependencies

When the user's `start.sh` script is run, it is helpful to use the Raspberry Pi `apt-get` utility to install dependencies that are needed by the project.  However, in the case of what we are looking to achieve here with a fixed operating system image this can become inefficient.

Each time we want to re-deploy the image to the Raspberry Pi we will be forced to wait for the duration of these `apt-get` calls to complete which can become time-consuming if we are iterating on the user application.

We can optimise this process by downloading the dependencies once, then keeping a copy of the `.deb`
resulting package files. These can then be installed by the user's application on first run instead of using the Internet to perform the `apt-get` commands. This allows us to cut down on time spent downloading and updating packages.

As an example, we can download the required dependencies for the Java 8 JRE and extract the dependency files:
```
sudo apt-get update
sudo apt-get install -d openjdk-8-jre-headless
```
This will place all the dependencies into the cache location `/var/cache/apt/archives`. From here we can copy these off the Raspberry Pi using `scp` and then store them for installation as part of the user's application.

Installation during the `start.sh` script is a simple as:

```
sudo dpkg -i /path/to/dependencies/*.deb
```
