#!/usr/bin/env bash
#
# Script to ping a server
# Rajendarreddy Jagapathi - 18/Mar/2017
# Usage
# chmod +x pingServer.sh
# bash pingServer.sh
read -p "Which server should be pinged " server_addr
ping -c3 $server_addr 2>&1 > /dev/null || echo "Server dead"
exit 0