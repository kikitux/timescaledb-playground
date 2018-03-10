#!/usr/bin/env python

import sys
import platform
import psycopg2
import time

lines = sys.stdin.read().split("\n")
metrics = [l.split("|") for l in lines if l]

if not metrics:
    print "nothing" 
    exit 

conn = psycopg2.connect(
"dbname='tutorial' " +
"user='tutorial' " +
"host='localhost' " +
"password='tutorial' " +
"port=5432"
)

cursor = conn.cursor()
query = "INSERT INTO nproc (time, hostname, nproc) VALUES (to_timestamp(%s), %s, %s);"

for key, value, timestamp in metrics:
    schema, table = key.split(".")
    cursor.execute("SET search_path TO " + schema)

    print schema, table, value, timestamp, platform.node()
    data = ( timestamp, platform.node(), value)
    cursor.execute(query, data)

conn.commit()
