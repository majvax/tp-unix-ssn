#!/bin/bash

SERVER=localhost
PORT=12344
KEY="QWERTYUIOPASDFGHJKLZXCVBNM"

send() {
  echo "$1" | tr 'A-Z' "$KEY" | tr 'a-z' "$(echo "$KEY" | tr 'A-Z' 'a-z')"
}

decode() {
  alphabet="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  echo "$1" | tr "$KEY" "$alphabet" | tr "$(echo "$KEY" | tr 'A-Z' 'a-z')" 'a-z'
}

function interpret() {
  read -r password
  send "$password"

  while read -r cmd; do
    send "$cmd"
  done
}

function recv() {
  while read -r response; do
    decode "$response"
  done
}

interpret | nc "$SERVER" "$PORT" | recv

echo "disconnected, au revoir!"
