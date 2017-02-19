#!/usr/bin/env python
# Requires Python 2+
# Usage
# python sqllite_crud.py
import sqlite3 as db
# or use :memory: to put it in RAM
conn = db.connect('mytest.db')
cursor = conn.cursor()
# drop table
cursor.execute("drop table if exists datecounts")
# create a table
cursor.execute("create table datecounts(date text, count int)")
# insert some data
cursor.execute('insert into datecounts values("12/1/2011",35)')
cursor.execute('insert into datecounts values("12/2/2011",42)')
cursor.execute('insert into datecounts values("12/3/2011",38)')
cursor.execute('insert into datecounts values("12/4/2011",41)')
cursor.execute('insert into datecounts values("12/5/2011",40)')
cursor.execute('insert into datecounts values("12/6/2011",28)')
cursor.execute('insert into datecounts values("12/7/2011",45)')
conn.row_factory = db.Row
cursor.execute("select * from datecounts")
rows = cursor.fetchall()
for row in rows:
   print("%s %s" % (row[0], row[1]))
cursor.execute("select avg(count) from datecounts")
row = cursor.fetchone()
print("The average count for the week was %s" % row[0])
cursor.execute("delete from datecounts where count = 40")
cursor.execute("select * from datecounts")
rows = cursor.fetchall()
for row in rows:
   print("%s %s" % (row[0], row[1]))
