#! /bin/bash
# PPA re-enable script
# Use: ppa-reenable source.list
# to reenable a PPA without its source line
# Use: ppa-reenable src source.list
# to reenable a PPA with its source line

mod=1
file="$1"
if [ $1 == "src" ]; then mod=""; file="$2"; fi;
sudo sed -i "${mod}s/^# \(.*\) \(disabled on upgrade.*\)\?/\1/" "$file"
