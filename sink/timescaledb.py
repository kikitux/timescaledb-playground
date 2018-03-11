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
"host='localhost' " +
"dbname='tutorial' " +
"user='tutorial' " +
"password='tutorial' " +
"port=5432"
)

cursor = conn.cursor()

for key, value, timestamp in metrics:
    schema, metric = key.split(".")   
    cursor.execute("SET search_path TO " + schema)
    print schema, metric, timestamp, platform.node(), value
    
    query = "INSERT INTO metrics (time, hostname, name, metric) VALUES (to_timestamp(%s), %s, %s, %s);"
    data = ( timestamp, platform.node(), metric, value)
    cursor.execute(query, data)

conn.commit()