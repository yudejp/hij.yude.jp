#!/bin/bash

# This script sets static IP address gracefully.

function set_ip {
    if /sbin/ethtool vpn_vpn | grep -q "Link detected: yes"; then
        ip addr add 192.168.31.2/22 dev vpn_vpn
    else
        sleep 5
        set_ip
    fi
}

apt -y install ethtool
set_ip

touch /var/vpn-connected
