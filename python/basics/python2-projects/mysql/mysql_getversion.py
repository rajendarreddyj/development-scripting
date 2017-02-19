#!/usr/bin/env python
# Requires Python 2+
# prerequisite
# sudo apt install python-pip python-dev libmysqlclient-dev
# upgrade package manager
# pip install --upgrade pip
# Install MySQL-python package
# pip install MySQL-python
# or
# sudo apt install python-mysqldb
# Usage
# python mysql_getversion.py
# retrieve and display database server version

import MySQLdb

# Instantiate connection object and connect to MySQL database
conn = MySQLdb.connect (host="localhost",
                        user="root",
                        passwd="toor",
                        db="test")
cursor = conn.cursor ()
cursor.execute ("SELECT VERSION()")
row = cursor.fetchone ()
print "server version:", row[0]
cursor.close ()
conn.close ()
