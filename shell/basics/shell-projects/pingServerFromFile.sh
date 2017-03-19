#!/usr/bin/env bash
#
# Script to ping servers from file
# Rajendarreddy Jagapathi - 18/Mar/2017
# Usage
# chmod +x pingServerFromFiles.sh
# bash pingServerFromFiles.sh serverLists.txt
if [ "$#" -ne 1 ] ; then
echo "The input to $0 should be a filename"
exit 1
fi
echo "The following servers are up on $(date +%x)"> server.out
# While loop to read line by line
# Use IFS= before read to avoid removing leading and trailing spaces.
while IFS= read -r server
do
ping -c1 "$server"&& echo "Server up: $server">> server.out
done < $1
cat server.out
exit 0