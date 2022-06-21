#!/bin/sh

set -e
set -x

#for package in $(npm -g outdated --parseable --depth=0 | cut -d: -f3)
for package in $(npm -g outdated --parseable --depth=0 | cut -d: -f4)
do
    npm -g install "$package"
done
