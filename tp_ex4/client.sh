#!/bin/bash

SERVER=localhost
PORT=12344

function interpret() {
  while true; do
    read -rp "> " cmd
    echo "$cmd"
  done
}

interpret | nc "$SERVER" "$PORT"
echo "disconnected, au revoir!"
