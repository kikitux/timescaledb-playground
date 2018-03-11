#!/usr/bin/env bash

  #echo -n "rewards:1|c" >/dev/udp/localhost/8125

while true; do
  echo -n "nproc:`ps aux  | wc -l`|g" >/dev/udp/localhost/8125
  echo -n "."
  sleep 5
done
