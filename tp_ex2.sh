#!/bin/bash
# shellcheck disable=SC2181 # disable style check for line 39 


IP=localhost
PORT=12345

rm ./fifo
mkfifo ./fifo
is_open=true


function interpret () {
  while read -r line ; do
    # Allow the client to close the server
    # This will ensure that the socket close properly
    # So the port is reusable
    if [ "$line" = "/close" ] ; then
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


while [ "$is_open" = true ]
do
  # shellcheck disable=SC2094 
  nc -l -s "$IP" -p "$PORT" < ./fifo | ( interpret ) > ./fifo

  # Use the error code of interpret cause
  # the function is running in a subshell
  if [ $? -ne 0 ] ; then
    is_open=false
  fi
done
