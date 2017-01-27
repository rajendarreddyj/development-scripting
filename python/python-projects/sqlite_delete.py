#!/usr/bin/env python
# Requires Python 2+
# Usage
# python sqllite_delete.py
import sqlite3

conn = sqlite3.connect("mydatabase.db")
cursor = conn.cursor()

sql = """
DELETE FROM albums
WHERE artist = 'John Doe'
"""
cursor.execute(sql)
conn.commit()
