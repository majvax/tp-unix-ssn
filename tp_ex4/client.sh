#!/bin/bash

SERVER=localhost
PORT=12345

function interpret () {
  while true; do
    read -rp "> " cmd
    if [ "$cmd" == "/exit" ]; then
      return 1
    else
      echo "$cmd"
    fi
  done
}

# Ugly way to exit the process killing
# the current script but hey, it work ?
( interpret; kill $$ ) | nc "$SERVER" "$PORT"
