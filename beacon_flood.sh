#!/bin/bash

i=0
# Trap for Ctrl + C
trap ctrl_c INT
function ctrl_c(){
  # Stops monitor mode and renables wifi
  systemctl restart NetworkManager > /dev/null 2>&1
  airmon-ng stop wlan0mon > /dev/null 2>&1
  ifconfig wlan0 up > /dev/null 2>&1
  rm aps.txt
}

command -v systemctl >/dev/null 2>&1 || { echo >&2 "Systemctl is not installed. Aborting."; exit 1; }
command -v airmon-ng >/dev/null 2>&1 || { echo >&2 "Airmon-ng is not installed.  Aborting."; exit 1; }
command -v mdk3 >/dev/null 2>&1 || { echo >&2 "Mdk3 is not installed.  Aborting."; exit 1; }
# Generates 1000 aps with selected name
until [ $i -gt 1000 ]
do
  # The '$i' can be removed
  echo "$1 $i" >> aps.txt
  ((i++))
done

# Starts monitor mode
airmon-ng check kill > /dev/null 2>&1
airmon-ng start wlan0 > /dev/null 2>&1

# Starts generating aps
mdk3 wlan0mon b -a -f aps.txt
# Parameters: -a (WPA2 AP)
