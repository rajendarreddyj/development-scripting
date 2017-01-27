#!/usr/bin/env python
# Requires Python 2+
# Usage
# python sqllite_update.py
import sqlite3

conn = sqlite3.connect("mydatabase.db")
cursor = conn.cursor()

sql = """
UPDATE albums
SET artist = 'John Doe'
WHERE artist = 'Andy Hunter'
"""
cursor.execute(sql)
conn.commit()
