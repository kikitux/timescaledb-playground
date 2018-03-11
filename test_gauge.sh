#!/usr/bin/env bash

echo "test_g:0 +1"
echo -n "test_g:0|g" >/dev/udp/localhost/8125
while true; do
  echo -n "test_g:+1|g" >/dev/udp/localhost/8125
  echo -n "."
  sleep 0.${RANDOM}
done
