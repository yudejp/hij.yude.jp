#!/bin/bash

# This script tests if VPN connection is truly established
# beforehand that the other services start.

FILE=/var/vpn-connected

sleep 10

if test -f "$FILE"; then
    echo "OK"
    exit 0
else
    echo "NG"
    exit 1
fi
