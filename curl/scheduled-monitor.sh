#!/bin/bash

# Scheduled monitoring script
# This script runs the server_monitor.sh at regular intervals

# Check if duration parameter is provided
if [ $# -ne 1 ]; then
  echo "Usage: $0 <duration_in_minutes>"
  exit 1
fi

duration=$1
interval=60 # seconds
iterations=$((duration * 60 / interval))

echo "Starting scheduled monitoring for $duration minutes..."
echo "Press Ctrl+C to stop monitoring"

for ((i = 1; i <= iterations; i++)); do
  echo -e "\n===== Run $i of $iterations ====="
  ./server_monitor.sh

  # Don't sleep after the last iteration
  if [ $i -lt $iterations ]; then
    echo "Next check in $interval seconds..."
    sleep $interval
  fi
done

echo "Scheduled monitoring completed."
