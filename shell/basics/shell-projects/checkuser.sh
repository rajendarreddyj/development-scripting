#!/usr/bin/env bash
# A Simple Shell Script To check user and exit if user is not root
# Rajendarreddy Jagapathi - 29/Jun/2018
# File: checkuser
if [ `whoami` != root ]; then
    echo "Must be user root to start Basecamp"
    exit 1
fi
