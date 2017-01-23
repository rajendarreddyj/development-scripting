#!/bin/bash
#
# Script to print user information who currently login , current date & time
# Rajendarreddy Jagapathi - 23/Jan/2017
clear
echo "Hello $USER"
echo -e "Today is \c ";date
echo -e "Number of user login : \c" ; who | wc -l
echo "Calendar"
cal
exit 0
