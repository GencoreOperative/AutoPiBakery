# Build

To build this Docker project from this source code we can use the following command:
```
docker build -t auto-pi-bakery:raspbian-jessie .
```

# Service Installation

The Docker image includes a systemd service which is installed by modifying the first_run.sh script to install the service. This only needs to be done once for the system so makes sense to include in the first_run script. This script automatically deletes itself once complete.


Installing a Service
https://www.raspberrypi.org/documentation/linux/usage/systemd.md

# Can't set up loop

When developing on the project we will need to iterate a number of times. We noticed that eventually there was an error around this. The cause of this is the behaviour of the loop back devices which are emulated within Docker. As the Linux container uses them and unmounts them the Docker host does not appear to unmount them. This means once all 8 are used up the Docker host needs restarting.

```
mount: could not find any device /dev/loop#Bad address
can't set up loop
```

# GNU Patch

In order to efficiently patch the original files we can use GNU Patch to apply diffs. The following sequence downloads and compiles the binary for the Pi.
```
cd /tmp && curl -s https://ftp.gnu.org/gnu/patch/patch-2.7.tar.gz | tar xvzf - && cd /tmp/patch-2.7/ && ./configure && make && make install
```

# Notes on debugging installation

The `pibuilder.sh` script modifies the `rc.local` file to trigger the first_run.sh script. This script will run when the rc.local service is started and run a series of steps to update the system. Some of these

# Balena Etcher
Disable DropBox as it appears to like bothering the SDCard each time it is connected. This causes Etcher to bail repeatedly.