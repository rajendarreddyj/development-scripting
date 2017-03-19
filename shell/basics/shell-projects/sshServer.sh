#!/usr/bin/env bash
#
# Script to prompt for ssh connection
# Rajendarreddy Jagapathi - 18/Mar/2017
# Usage
# chmod +x pingServer.sh
# bash pingServer.sh
read -p "Which server do you want to connect to: " server_name
read -p "Which username do you want to use: " user_name
ssh ${user_name}@$server_name
exit 0