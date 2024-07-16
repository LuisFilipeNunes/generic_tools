#!/bin/bash

# Backup the current resolv.conf file
cp /etc/resolv.conf /etc/resolv.conf.backup

> /etc/resolv.conf
# Add the nameservers to resolv.conf
echo "nameserver 192.168.200.18" >> /etc/resolv.conf
echo "nameserver 192.168.201.18" >> /etc/resolv.conf

echo "Nameservers added successfully."
