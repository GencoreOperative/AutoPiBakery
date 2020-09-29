#!/bin/bash

while [[ true ]]; do
    echo 1 | sudo tee /sys/class/leds/led0/brightness
    sleep 0.1
    echo 0 | sudo tee /sys/class/leds/led0/brightness
done