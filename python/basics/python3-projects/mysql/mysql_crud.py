#!/usr/bin/env python
# Requires Python 3+
# prerequisite
# sudo apt install python3-pip libmysqlclient-dev
# upgrade package manager
# sudo python3 -m pip install --upgrade pip
# Install MySQL-python package
# sudo python3 -m pip install pymysql
# My sql Crud operations using python
# Usage
# python mysql_crud.py
import pymysql

# Instantiate connection object and connect to MySQL database
conn = pymysql.connect(host="localhost", user="root", passwd="toor", db="test")

# Instantiate cursor object
cursor = conn.cursor()

# Drop Table
cursor.execute("DROP TABLE IF EXISTS TableTest")

# Create Table
cursor.execute("CREATE TABLE TableTest(Id INT PRIMARY KEY AUTO_INCREMENT, \
             Name VARCHAR(25))")
# Insert Some Data
cursor.execute("INSERT INTO TableTest(Name) VALUES('TestData1')")
cursor.execute("INSERT INTO TableTest(Name) VALUES('TestData2')")
cursor.execute("INSERT INTO TableTest(Name) VALUES('TestData3')")
cursor.execute("INSERT INTO TableTest(Name) VALUES('TestData4')")
cursor.execute("INSERT INTO TableTest(Name) VALUES('TestData5')")
conn.commit()

# Retrieve Data
# execute SQL select statement
cursor.execute("SELECT Id,Name FROM TableTest")

rows = cursor.fetchall()

# Iterate
# get and display one row at a time.
for row in rows:
    # data from rows
    print(row)

# Update Table
cursor.execute("UPDATE TableTest SET Name = %s WHERE Id = %s",
        ("TestData41", "4"))

print("Number of rows updated:", cursor.rowcount)

# Delete
cursor.execute("DELETE FROM TableTest WHERE Id = %s", "2")

print("Number of rows deleted:", cursor.rowcount)

# Close cursor
cursor.close ()
# Close database connection
conn.close()
