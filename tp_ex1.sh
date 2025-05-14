#!/bin/bash

IP=localhost
PORT=12345

rm ./fifo
mkfifo ./fifo

function interpret () {
  echo "Bienvenue"
  echo $(date)
}

while true
do
  nc -l -s "$IP" -p "$PORT" < ./fifo | interpret > ./fifo
done
