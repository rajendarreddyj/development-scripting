#!/usr/bin/env bash
#
# Script to convert file to UTF-8 Encoding
# Rajendarreddy Jagapathi - 23/Feb/2017
# Usage
# chmod +x encodefile.sh
# bash encodefile.sh
#enter input encoding here
FROM_ENCODING="value_here"
#output encoding(UTF-8)
TO_ENCODING="UTF-8"
#convert
CONVERT=" iconv  -f   $FROM_ENCODING  -t   $TO_ENCODING"
#loop to convert multiple files 
for  file  in  *.txt; do
$CONVERT   "$file"   -o  "${file%.txt}.utf8.converted"
done
exit 0