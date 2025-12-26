#!/bin/bash

createTunnel() {

  # ask remote_server to open (as remote_user) port 6742 as a proxy to local port 22
  /usr/bin/ssh -N -R 6742:localhost:22 remote_user@remote_server

  if [[ $? -eq 0 ]]; then
    echo Tunnel created successfully
  else
    echo An error occurred creating a tunnel. Return code is $?
  fi
}

/bin/pidof ssh
if [[ $? -ne 0 ]]; then
  echo Creating new tunnel connection
  createTunnel
fi

