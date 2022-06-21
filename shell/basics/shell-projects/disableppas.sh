#! /bin/bash
# PPA disable script
# Use: ppa-disable source.list
# to disable the PPA completely
# Use: ppa-disable src source.list
# to disable the source of the PPA only

file="${1}"
mod=""
# If its only needed to disable the source
if [ $1 = "src" ]; then mod="2"; file="${2}"; fi;

# If source line is disabled, don't comment it out
second="`sed -n 2p \"$file\"`"
second="${second:0:1}"
if ( [ $second == "#" ] && [ $mod != "2" ] ); then
    mod="1"
fi

sudo sed -i "${mod}s/^/# /" "$file"
