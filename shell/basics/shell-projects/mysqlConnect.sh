#!/usr/bin/env bash
#
# Script to prompt for MYSQL user password and command
# Rajendarreddy Jagapathi - 18/Mar/2017
# Usage
# chmod +x mysqlConnect.sh
# bash mysqlConnect.sh
read -p "MySQL User: " user_name
read -sp "MySQL Password: " mysql_pwd
echo
read -p "MySQL Command: " mysql_cmd
read -p "MySQL Database: " mysql_db
mysql -u $user_name -p$mysql_pwd$mysql_db -e"$mysql_cmd"
exit 0