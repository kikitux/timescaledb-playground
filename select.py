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

#show current minute
cursor.execute("select hostname, metric, name from metrics where time >= date_trunc('minute', current_timestamp)")
for record in cursor:
    print record
