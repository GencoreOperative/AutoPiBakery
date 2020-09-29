FROM riggerthegeek/pibuilder:0.2.1

# Download the Raspbian Jessie base image from raspberrypi.org. It needs to be named
# as the MD5 sum of the URL text for the script to pick it up in the cache
RUN mkdir /opt/pibuilder/cache && \
curl -# https://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2017-07-05/2017-07-05-raspbian-jessie-lite.zip -o /opt/pibuilder/cache/os.76a0dae971f3a690a6422b6babbf2840.zip

# Output folder is used for finished Raspberry Pi image
RUN mkdir /output

# Copy in fixed settings known before runtime.
COPY settings.sh /opt/pibuilder/settings.sh

#
# User Application Service: Copy in the service
# The users scripts will be located in /input
#

COPY service/user.service /opt/pibuilder/user.service
RUN mkdir /input

#
# Patching: Patch the pibuilder scripts to install the service
#

# Download and compile GNU Patch for easy patching of pibuilder.sh script
RUN cd /tmp && curl -s https://ftp.gnu.org/gnu/patch/patch-2.7.tar.gz | tar xvzf - && cd /tmp/patch-2.7/ && ./configure && make && make install

COPY patches/pibuilder.patch /opt/pibuilder/scripts
RUN cd /opt/pibuilder/scripts && patch pibuilder.sh pibuilder.patch && rm pibuilder.patch

COPY patches/first_run.patch /opt/pibuilder/scripts
RUN cd /opt/pibuilder/scripts && patch first_run.sh first_run.patch && rm first_run.patch

#
# Command: Override the default pibuilder.sh with runtime which will handle runtime
# level tasks.
#
COPY runtime.sh /opt/pibuilder/runtime.sh
CMD sh /opt/pibuilder/runtime.sh