#!/bin/bash
printf "%s" "Waiting for getting VPN online."
while ! timeout 0.2 ping -c 1 -n 192.168.28.1 &> /dev/null
do
    printf "%c" "."
done
printf "\n%s\n"  "Successfully connected to the VPN server."
