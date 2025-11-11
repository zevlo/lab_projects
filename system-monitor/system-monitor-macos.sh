#!/bin/bash

# Define threshold values for CPU, memory, and disk usage (in percentage)
CPU_THRESHOLD=80
MEMORY_THRESHOLD=80
DISK_THRESHOLD=80

# Log file in home directory
LOG_FILE="$HOME/resource_usage.log"

# Function to send an alert
send_alert() {
  printf "\033[31mALERT: %s usage exceeded threshold! Current value: %d%%\033[0m\n" "$1" "$2"
}

# Main monitoring loop
while true; do
  # Monitor CPU using top (single snapshot)
  cpu_usage=$(top -l 1 -n 0 | grep "CPU usage" | awk '{print int($3 + $5)}')
  if [ "$cpu_usage" -ge "$CPU_THRESHOLD" ]; then
    send_alert "CPU" "$cpu_usage"
  fi

  # Monitor memory using vm_stat
  memory_stats=$(vm_stat | grep -E "Pages active|Pages free")
  pages_active=$(echo "$memory_stats" | grep "Pages active" | awk '{print $3}' | tr -d '.')
  pages_free=$(echo "$memory_stats" | grep "Pages free" | awk '{print $3}' | tr -d '.')
  memory_usage=$(( (pages_active * 100) / (pages_active + pages_free) ))
  if [ "$memory_usage" -ge "$MEMORY_THRESHOLD" ]; then
    send_alert "Memory" "$memory_usage"
  fi

  # Monitor disk using df
  disk_usage=$(df -h / | awk '/\// {print $(NF-1)}' | tr -d '%')
  if [ "$disk_usage" -ge "$DISK_THRESHOLD" ]; then
    send_alert "Disk" "$disk_usage"
  fi

  # Display current stats
  clear
  printf "Resource Usage:\n"
  printf "CPU: %d%%\n" "$cpu_usage"
  printf "Memory: %d%%\n" "$memory_usage"
  printf "Disk: %d%%\n" "$disk_usage"

  # Log resource usage to a file
  log_entry="$(date '+%Y-%m-%d %H:%M:%S') CPU: $cpu_usage% Memory: $memory_usage% Disk: $disk_usage%"
  echo "$log_entry" >> "$LOG_FILE"

  sleep 2
done
