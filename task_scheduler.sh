#!/bin/bash

# Function to display the scheduled tasks
list_tasks() {
  echo "Scheduled tasks:"
  crontab -l
  echo
}

# Function to add a new task
add_task() {
  read -p "Enter the command or script to be executed: " command
  read -p "Enter the schedule (hourly, daily, weekly): " schedule
  read -p "Enter any additional parameters: " parameters

  case $schedule in
    hourly)
      cron_schedule="0 * * * *"
      ;;
    daily)
      cron_schedule="0 0 * * *"
      ;;
    weekly)
      cron_schedule="0 0 * * 0"
      ;;
    *)
      echo "Invalid schedule. Please choose hourly, daily, or weekly."
      return
      ;;
  esac

  # Add the task to the crontab
  (
    crontab -l 2> /dev/null
    echo "$cron_schedule $command $parameters"
  ) | crontab -

  echo "Task scheduled successfully."
  echo
}

# Function to remove a task
remove_task() {
  # Get current crontab entries
  local tasks=$(crontab -l 2>/dev/null)

  if [ -z "$tasks" ]; then
    echo "No scheduled tasks found."
    echo
    return
  fi

  # Display tasks with line numbers
  echo "Current scheduled tasks:"
  echo "$tasks" | nl -w 2 -s '. '
  echo

  read -p "Enter the task number to remove (or 0 to cancel): " task_num

  # Validate input
  if [ "$task_num" -eq 0 ] 2>/dev/null; then
    echo "Removal cancelled."
    echo
    return
  fi

  local total_tasks=$(echo "$tasks" | wc -l | tr -d ' ')

  if ! [[ "$task_num" =~ ^[0-9]+$ ]] || [ "$task_num" -lt 1 ] || [ "$task_num" -gt "$total_tasks" ]; then
    echo "Invalid task number."
    echo
    return
  fi

  # Show the task to be removed
  local task_to_remove=$(echo "$tasks" | sed -n "${task_num}p")
  echo "Task to be removed: $task_to_remove"
  read -p "Are you sure? (y/n): " confirm

  if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "Removal cancelled."
    echo
    return
  fi

  # Remove the specific task
  echo "$tasks" | sed "${task_num}d" | crontab -

  echo "Task removed successfully."
  echo
}

# Main menu loop
while true; do
  echo "Task Scheduler"
  echo "1. List scheduled tasks"
  echo "2. Add a task"
  echo "3. Remove a task"
  echo "4. Exit"
  read -p "Enter your choice: " choice
  echo

  case $choice in
    1)
      list_tasks
      ;;
    2)
      add_task
      ;;
    3)
      remove_task
      ;;
    4)
      break
      ;;
    *)
      echo "Invalid choice. Please try again."
      echo
      ;;
  esac
done