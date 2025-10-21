#!/bin/bash

# get.sh - Get information about the program running on a specified port.
# This script checks for a program listening on a given TCP port.
# If no program is found, it prints "OK".
# Otherwise, it prints the PID and the full command path.

# Check if a port number is provided as an argument.
if [ -z "$1" ]; then
  echo "Usage: $0 <port_number>"
  exit 1
fi

port_number=$1

# Use lsof to find the PID of the process listening on the specified port.
# -i :$port_number: Search for processes with internet files open on this port.
# -sTCP:LISTEN: Filter for TCP connections in the LISTEN state.
# -Fp: Output only the PID, prefixed with 'p'.
pid=$(lsof -i :$port_number -sTCP:LISTEN -Fp | sed 's/^p//')

# Check if a process was found.
if [ -z "$pid" ]; then
  echo "OK"
else
  # Use ps to get the full command path for the given PID.
  # -p $pid: Specify the process ID.
  # -o comm=: Get the command name (executable path).
  command_path=$(ps -p $pid -o comm=)
  echo "PID: $pid"
  echo "Command: $command_path"
fi%
