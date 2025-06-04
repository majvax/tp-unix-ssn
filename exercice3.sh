#!/bin/bash
# shellcheck disable=SC2181,SC2094

IP=localhost
PORT=12345

rm ./fifo
mkfifo ./fifo
is_open=true

source configuration.conf

# check if password exists
# see https://stackoverflow.com/a/13864829/214577 for reference
if [ -z ${password+x} ]; then
  echo "missing 'password' key in configuration.conf"
  exit 1
fi

function interpret() {
  echo "Veuiller entrer un mot de passe."
  read -r pswd
  if [ "$password" != "$pswd" ]; then
    echo "Mot de passe faux."
    return 0
  fi

  echo "Mot de passe bon!"

  while read -r line; do
    # Allow the client to close the server
    # This will ensure that the socket close properly
    # So the port is reusable
    if [ "$line" == "/close" ]; then
      echo "bye bye!"
      return 1
    else
      # Run the line using bash -c
      # so argument are preserved (like 'ls -l .')
      # See 'man bash' for reference
      bash -c "$line"
    fi
  done
  return 0
}

while [ "$is_open" = true ]; do
  nc -l -s "$IP" -p "$PORT" <./fifo | (interpret) >./fifo

  # Use the error code of interpret cause
  # the function is running in a subshell
  if [ $? -ne 0 ]; then
    is_open=false
  fi
done
