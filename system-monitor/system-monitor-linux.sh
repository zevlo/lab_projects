#!/bin/bash

# Define the threshold values for CPU, memory, and disk usage (in percentage)
CPU_THRESHOLD=80
MEMORY_THRESHOLD=80
DISK_THRESHOLD=80

# Log file path (set to a file in the current directory)
LOG_FILE="system_monitor.log"

# Maximum iterations before the script stops automatically (set high for practical indefinite running, but allows finite testing)
MAX_ITERATIONS=100000

# Function to send an alert
send_alert() {
  echo "$(tput setaf 1)ALERT: $1 usage exceeded threshold! Current value: $2%$(tput sgr0)"
}

# Initialize iteration counter
iteration=0

# Main monitoring loop
while true; do
  # Check if we've reached maximum iterations
  if (( iteration >= MAX_ITERATIONS )); then
    echo "Maximum iterations reached. Exiting..."
    break
  fi

  # Monitor CPU
  cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{printf "%.0f", $2 + $4}')
  if ((cpu_usage >= CPU_THRESHOLD)); then
    send_alert "CPU" "$cpu_usage"
  fi

  # Monitor memory
  memory_usage=$(free | awk '/Mem/ {printf("%.0f", ($3/$2) * 100)}')
  if ((memory_usage >= MEMORY_THRESHOLD)); then
    send_alert "Memory" "$memory_usage"
  fi

  # Monitor disk
  disk_usage=$(df -h / | awk '/\// {print $(NF-1)}' | sed 's/%//')
  if ((disk_usage >= DISK_THRESHOLD)); then
    send_alert "Disk" "$disk_usage"
  fi

  # Display current stats
  clear
  echo "Resource Usage (Iteration $iteration):"
  echo "CPU: $cpu_usage%"
  echo "Memory: $memory_usage%"
  echo "Disk: $disk_usage%"

  # Log resource usage to a file
  log_entry="$(date '+%Y-%m-%d %H:%M:%S') CPU: $cpu_usage% Memory: $memory_usage% Disk: $disk_usage%"
  echo "$log_entry" >> "$LOG_FILE"

  sleep 2
  (( iteration++ ))
done
