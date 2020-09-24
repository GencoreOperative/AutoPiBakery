FROM riggerthegeek/pibuilder:0.2.1

# Build time

# Draw in the Jessie image and place in the correct location with a specific filename
# The target image needs to be named as the MD5 sum of the URL text script to pick it up
# https://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2017-07-05/2017-07-05-raspbian-jessie-lite.zip becomes 76a0dae971f3a690a6422b6babbf2840
COPY 2017-07-05-raspbian-jessie-lite.zip /opt/pibuilder/cache/os.76a0dae971f3a690a6422b6babbf2840.zip

# Draw in the settings file which we will modify at runtime.
COPY settings.sh /opt/pibuilder/settings.sh

COPY runtime.sh /opt/pibuilder/runtime.sh

COPY zero.pub /ssh-keys

CMD sh /opt/pibuilder/runtime.sh