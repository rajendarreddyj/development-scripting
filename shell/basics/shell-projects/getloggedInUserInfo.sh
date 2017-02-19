#!/usr/bin/env bash
#
# Script to print user information who currently login , current date & time
# Rajendarreddy Jagapathi - 23/Jan/2017
# Usage
# chmod +x getloggedInUserInfo.sh
# bash getloggedInUserInfo.sh
clear
echo "Hello $USER"
echo -e "Today is \c ";date
echo -e "Number of user login : \c" ; who | wc -l
echo "Users currently on the machine, and their processes:"
w
echo "Calendar"
cal
exit 0
