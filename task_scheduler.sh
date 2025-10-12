#!/bin/bash

# Function to display the scheduled tasks
list_tasks() {
  echo "Scheduled tasks:"
  crontab -l
  echo
}