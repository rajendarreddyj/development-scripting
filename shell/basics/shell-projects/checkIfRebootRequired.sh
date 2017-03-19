#!/usr/bin/env bash
#
# Script to check if Reboot is required on ubuntu
# Rajendarreddy Jagapathi - 18/Mar/2017
# Usage
# chmod +x checkIfRebootRequired.sh
# bash checkIfRebootRequired.sh
if [ -f /var/run/reboot-required ]; then
  echo 'reboot required'
fi