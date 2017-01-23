#!/bin/bash
# A Simple Shell Script To Get Linux Network Information
# Rajendarreddy Jagapathi - 23/Jan/2017
# Usage
# chmod +x getNetworkInfo.sh
# bash getNetworkInfo.sh
echo "Current date : $(date) @ $(hostname)"
echo "Network configuration"
/sbin/ifconfig
