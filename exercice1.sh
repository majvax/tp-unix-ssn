#!/bin/bash

IP=localhost
PORT=12345

rm ./fifo
mkfifo ./fifo

function interpret () {
  echo "Bienvenue"
  date
}

while true
do
  # shellcheck disable=SC2094 
  nc -l -s "$IP" -p "$PORT" < ./fifo | ( interpret ) > ./fifo
done
