#!/usr/bin/env python

import psycopg2
import time

conn = psycopg2.connect(
"dbname='tutorial' " +
"user='tutorial' " +
"host='localhost' " +
"password='tutorial' " +
"port=5432"
)

cursor = conn.cursor()
cursor.execute("SET search_path TO " + "gauges")

query = "INSERT INTO nproc (time, hostname, nproc) VALUES (to_timestamp(%s), %s, %s);"

thetime = int(time.time())
data = ( thetime, "timescaledb", "100")
cursor.execute(query, data)
conn.commit()
