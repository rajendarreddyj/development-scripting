#!/usr/bin/env bash
#
# Script to read name from console 
# Rajendarreddy Jagapathi - 18/Mar/2017
# Usage
# chmod +x readName.sh
# bash readName.sh
read -p "What is your name: " name
echo "Hello $name"
# -s will hide entered text
# n1 will limit to read only one keystroe
read -sn1 -p "Press any key to exit"
echo
exit 0