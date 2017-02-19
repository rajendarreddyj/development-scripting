#!/usr/bin/env python
# Requires Python 3+
# prerequisite
# sudo apt install python3-pip libmysqlclient-dev
# upgrade package manager
# sudo python3 -m pip install --upgrade pip
# Install MySQL-python package
# sudo python3 -m pip install pymysql
# Usage
# python mysql_getversion.py
# retrieve and display database server version

import pymysql

# Instantiate connection object and connect to MySQL database
conn = pymysql.connect (host="localhost",
                        user="root",
                        passwd="toor",
                        db="test")
cursor = conn.cursor ()
cursor.execute ("SELECT VERSION()")
row = cursor.fetchone ()
print("server version:", row[0])
cursor.close ()
conn.close ()
