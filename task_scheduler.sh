#!/bin/bash

# Function to display the scheduled tasks
list_tasks() {
  local tasks=$(crontab -l 2>/dev/null)

  if [ -z "$tasks" ]; then
    echo "No scheduled tasks found."
    echo
    return
  fi

  echo "Scheduled tasks:"
  echo "$tasks"
  echo
}

# Function to add a new task
add_task() {
  read -p "Enter the command or script to be executed: " command

  # Validate command is not empty
  if [ -z "$command" ]; then
    echo "Error: Command cannot be empty."
    echo
    return
  fi

  # Check if command exists (extract just the command name, not full path or parameters)
  local cmd_name=$(echo "$command" | awk '{print $1}')
  if ! command -v "$cmd_name" &> /dev/null && [ ! -f "$cmd_name" ]; then
    echo "Warning: Command '$cmd_name' not found in PATH or as a file."
    read -p "Do you want to continue anyway? (y/n): " continue_choice
    if [ "$continue_choice" != "y" ] && [ "$continue_choice" != "Y" ]; then
      echo "Task scheduling cancelled."
      echo
      return
    fi
  fi

  read -p "Enter the schedule (hourly, daily, weekly): " schedule

  # Validate and normalize schedule input
  schedule=$(echo "$schedule" | tr '[:upper:]' '[:lower:]' | xargs)

  if [ -z "$schedule" ]; then
    echo "Error: Schedule cannot be empty."
    echo
    return
  fi

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
      echo "Error: Invalid schedule '$schedule'. Please choose hourly, daily, or weekly."
      echo
      return
      ;;
  esac

  read -p "Enter any additional parameters (press Enter to skip): " parameters

  # Show what will be added
  echo
  echo "The following task will be scheduled:"
  echo "Schedule: $schedule ($cron_schedule)"
  echo "Command: $command $parameters"
  echo
  read -p "Confirm? (y/n): " confirm

  if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "Task scheduling cancelled."
    echo
    return
  fi

  # Add the task to the crontab
  (
    crontab -l 2> /dev/null
    echo "$cron_schedule $command $parameters"
  ) | crontab -

  echo "Task scheduled successfully!"
  echo "Run 'crontab -l' to verify, or use option 1 to list tasks."
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

  # Validate choice input
  if [ -z "$choice" ]; then
    echo "Error: Please enter a choice."
    echo
    continue
  fi

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
      echo "Exiting Task Scheduler. Goodbye!"
      break
      ;;
    *)
      echo "Error: Invalid choice '$choice'. Please enter a number between 1 and 4."
      echo
      ;;
  esac
done