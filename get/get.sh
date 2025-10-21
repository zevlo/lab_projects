#!/bin/bash

# get.sh - Get Running Program on a Specified Port
# This script checks if a program is running on a specified port. If no program is running, it prints "OK".

# Check if the port number is provided as an argument
if [ -z "$1" ]; then
  echo "Please provide a port number."
  exit 1
fi

# Get the port number
port=$1

# Check if the port is in use
process=$(lsof -i :$port -sTCP:LISTEN -Fp | sed 's/^p//')

# Check if a program is running
if [ -z "$process" ]; then
  echo "OK"
else
  # Get the full path of the program
  path=$(ps -p $process -o args=)
  echo "$path" | awk '{print $1}'
fi
