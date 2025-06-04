#!/bin/bash
# shellcheck disable=SC2181,SC2094,SC2019,SC2018,SC1091

IP=localhost
PORT=12344

send() {
  echo "$1" | tr 'A-Z' "$2" | tr 'a-z' "$(echo "$2" | tr 'A-Z' 'a-z')"
}

decode() {
  echo "$1" | tr "$2" 'A-Z' | tr "$(echo "$2" | tr 'A-Z' 'a-z')" 'a-z'
}

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

if [ -z ${key+x} ]; then
  echo "missing 'key' key in configuration.conf"
  exit 1
fi

function interpret() {
  send "Veuiller entrer un mot de passe." "$key"
  read -r pswd
  pswd=$(decode "$pswd" "$key")
  if [ "$password" != "$pswd" ]; then
    send "Mot de passe faux." "$key"
    return 0
  fi

  send "Mot de passe bon!" "$key"

  while read -r line; do
    # Allow the client to close the server
    # This will ensure that the socket close properly
    # So the port is reusable
    line=$(decode "$line" "$key")
    if [ "$line" == "/close" ]; then
      send "bye bye!" "$key"
      return 1
    # Close the client by breaking the loop
    # It kinda work.
    elif [ "$line" == "/exit" ]; then
      return 0
    elif [ "$line" == "/help" ]; then
      send "Available commands:" "$key"
      send "  /close: close the server" "$key"
      send "  /exit: exit the server" "$key"
      send "  /help: show this help message" "$key"
      send "  <any other command>: execute the command in bash" "$key"
    elif [ -z "$line" ]; then
      # Ignore empty lines
      continue
    else
      # Run the line using bash -c
      # so argument are preserved (like 'ls -l .')
      # See 'man bash' for reference
      # 2>&1 redirect standard error to standard output
      output=$(bash -c "$line" 2>&1)
      send "$output" "$key"
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
