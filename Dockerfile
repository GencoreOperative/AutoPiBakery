FROM riggerthegeek/pibuilder:0.2.1

# Download the Raspbian Jessie base image from raspberrypi.org. It needs to be named
# as the MD5 sum of the URL text for the script to pick it up in the cache
RUN mkdir /opt/pibuilder/cache && \
curl -# https://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2017-07-05/2017-07-05-raspbian-jessie-lite.zip -o /opt/pibuilder/cache/os.76a0dae971f3a690a6422b6babbf2840.zip

# Input folder is used for users application
RUN mkdir /input

# Output folder is used for finished Raspberry Pi image
RUN mkdir /output

# Copy in fixed settings known before runtime.
COPY settings.sh /opt/pibuilder/settings.sh

# Runtime script handles all other setup
COPY runtime.sh /opt/pibuilder/runtime.sh

# Install GNU Patch so we can easily patch the pibuilder.sh script
RUN cd /tmp && curl -s https://ftp.gnu.org/gnu/patch/patch-2.7.tar.gz | tar xvzf - && cd /tmp/patch-2.7/ && ./configure && make && make install

COPY pibuilder.sh /opt/pibuilder/scripts/pibuilder.sh
COPY first_run.sh /opt/pibuilder/scripts/first_run.sh

# Patch the pibuilder.sh with functionality to support input files
#COPY pibuilder.patch /opt/pibuilder/pibuilder.patch
#RUN head -n 110 /opt/pibuilder/scripts/pibuilder.sh > /opt/pibuilder/scripts/pibuilder2.sh
#RUN cat /opt/pibuilder/pibuilder.patch >> /opt/pibuilder/scripts/pibuilder2.sh
#RUN tail -n 47 /opt/pibuilder/scripts/pibuilder.sh >> /opt/pibuilder/scripts/pibuilder2.sh
#RUN mv /opt/pibuilder/scripts/pibuilder2.sh /opt/pibuilder/scripts/pibuilder.sh

# Patch the pibuilder.sh with verify.patch
#COPY verify.patch /opt/pibuilder/verfiy.patch
#RUN head -n 116 /opt/pibuilder/scripts/pibuilder.sh > /opt/pibuilder/scripts/pibuilder2.sh
#RUN cat /opt/pibuilder/pibuilder.patch >> /opt/pibuilder/scripts/pibuilder2.sh
#RUN tail -n 41 /opt/pibuilder/scripts/pibuilder.sh >> /opt/pibuilder/scripts/pibuilder2.sh
#RUN mv /opt/pibuilder/scripts/pibuilder2.sh /opt/pibuilder/scripts/pibuilder.sh

CMD sh /opt/pibuilder/runtime.sh