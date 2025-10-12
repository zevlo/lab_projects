#!/bin/bash

# Check if crontab command is available
if ! command -v crontab &> /dev/null; then
  echo "Error: crontab command not found. This script requires cron to be installed."
  exit 1
fi

# Check if user has permission to use crontab
if ! crontab -l &> /dev/null && [ $? -ne 0 ] && ! echo "" | crontab - &> /dev/null; then
  echo "Error: You do not have permission to use crontab."
  echo "Please contact your system administrator."
  exit 1
fi

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

  echo "Schedule options:"
  echo "  1. Hourly (at the start of every hour)"
  echo "  2. Daily (custom time)"
  echo "  3. Weekly (custom day and time)"
  echo "  4. Every N minutes"
  read -p "Enter schedule choice (1-4): " schedule_choice

  # Validate schedule choice
  if [ -z "$schedule_choice" ]; then
    echo "Error: Schedule choice cannot be empty."
    echo
    return
  fi

  case $schedule_choice in
    1)
      cron_schedule="0 * * * *"
      schedule="hourly"
      ;;
    2)
      read -p "Enter hour (0-23, default 0 for midnight): " hour
      hour=${hour:-0}

      if ! [[ "$hour" =~ ^[0-9]+$ ]] || [ "$hour" -lt 0 ] || [ "$hour" -gt 23 ]; then
        echo "Error: Invalid hour. Must be between 0 and 23."
        echo
        return
      fi

      read -p "Enter minute (0-59, default 0): " minute
      minute=${minute:-0}

      if ! [[ "$minute" =~ ^[0-9]+$ ]] || [ "$minute" -lt 0 ] || [ "$minute" -gt 59 ]; then
        echo "Error: Invalid minute. Must be between 0 and 59."
        echo
        return
      fi

      cron_schedule="$minute $hour * * *"
      schedule="daily at $(printf '%02d:%02d' $hour $minute)"
      ;;
    3)
      echo "Days: 0=Sunday, 1=Monday, 2=Tuesday, 3=Wednesday, 4=Thursday, 5=Friday, 6=Saturday"
      read -p "Enter day (0-6, default 0 for Sunday): " day
      day=${day:-0}

      if ! [[ "$day" =~ ^[0-9]+$ ]] || [ "$day" -lt 0 ] || [ "$day" -gt 6 ]; then
        echo "Error: Invalid day. Must be between 0 and 6."
        echo
        return
      fi

      read -p "Enter hour (0-23, default 0): " hour
      hour=${hour:-0}

      if ! [[ "$hour" =~ ^[0-9]+$ ]] || [ "$hour" -lt 0 ] || [ "$hour" -gt 23 ]; then
        echo "Error: Invalid hour. Must be between 0 and 23."
        echo
        return
      fi

      read -p "Enter minute (0-59, default 0): " minute
      minute=${minute:-0}

      if ! [[ "$minute" =~ ^[0-9]+$ ]] || [ "$minute" -lt 0 ] || [ "$minute" -gt 59 ]; then
        echo "Error: Invalid minute. Must be between 0 and 59."
        echo
        return
      fi

      local day_names=("Sunday" "Monday" "Tuesday" "Wednesday" "Thursday" "Friday" "Saturday")
      cron_schedule="$minute $hour * * $day"
      schedule="weekly on ${day_names[$day]} at $(printf '%02d:%02d' $hour $minute)"
      ;;
    4)
      read -p "Enter interval in minutes (1-59): " interval

      if [ -z "$interval" ]; then
        echo "Error: Interval cannot be empty."
        echo
        return
      fi

      if ! [[ "$interval" =~ ^[0-9]+$ ]] || [ "$interval" -lt 1 ] || [ "$interval" -gt 59 ]; then
        echo "Error: Invalid interval. Must be between 1 and 59 minutes."
        echo
        return
      fi

      cron_schedule="*/$interval * * * *"
      schedule="every $interval minutes"
      ;;
    *)
      echo "Error: Invalid schedule choice '$schedule_choice'. Please enter 1, 2, 3, or 4."
      echo
      return
      ;;
  esac

  read -p "Enter any additional parameters (press Enter to skip): " parameters

  # Show what will be added
  echo
  echo "=========================================="
  echo "PREVIEW: Task to be scheduled"
  echo "=========================================="
  echo "Schedule: $schedule"
  echo "Cron format: $cron_schedule"
  echo "Command: $command $parameters"
  echo
  echo "Full crontab entry:"
  echo "  $cron_schedule $command $parameters"
  echo "=========================================="
  echo
  read -p "Do you want to add this task? (y/n): " confirm

  if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "Task scheduling cancelled."
    echo
    return
  fi

  # Add the task to the crontab
  if (
    crontab -l 2> /dev/null
    echo "$cron_schedule $command $parameters"
  ) | crontab - 2>/dev/null; then
    echo "Task scheduled successfully!"
    echo "Run 'crontab -l' to verify, or use option 1 to list tasks."
    echo
  else
    echo "Error: Failed to add task to crontab. Please check your permissions."
    echo
    return 1
  fi
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
  if echo "$tasks" | sed "${task_num}d" | crontab - 2>/dev/null; then
    echo "Task removed successfully."
    echo
  else
    echo "Error: Failed to remove task from crontab. Please check your permissions."
    echo
    return 1
  fi
}

# Trap to handle script interruption
trap 'echo ""; echo "Script interrupted. Exiting..."; exit 130' INT TERM

# Function to preview all tasks with explanations
preview_tasks() {
  local tasks=$(crontab -l 2>/dev/null)

  if [ -z "$tasks" ]; then
    echo "No scheduled tasks found."
    echo
    return
  fi

  echo "=========================================="
  echo "SCHEDULED TASKS WITH EXPLANATIONS"
  echo "=========================================="
  echo

  local count=0
  while IFS= read -r line; do
    ((count++))
    echo "Task #$count:"
    echo "  Cron entry: $line"

    # Extract cron schedule parts
    local minute=$(echo "$line" | awk '{print $1}')
    local hour=$(echo "$line" | awk '{print $2}')
    local day_month=$(echo "$line" | awk '{print $3}')
    local month=$(echo "$line" | awk '{print $4}')
    local day_week=$(echo "$line" | awk '{print $5}')
    local command=$(echo "$line" | cut -d' ' -f6-)

    # Interpret the schedule
    echo -n "  Runs: "

    # Check for interval patterns
    if [[ "$minute" == *"/"* ]]; then
      local interval=$(echo "$minute" | cut -d'/' -f2)
      echo "Every $interval minutes"
    elif [ "$minute" = "0" ] && [ "$hour" = "*" ]; then
      echo "Hourly (at the start of every hour)"
    elif [ "$hour" != "*" ] && [ "$day_week" = "*" ] && [ "$day_month" = "*" ]; then
      echo "Daily at $(printf '%02d:%02d' $hour $minute)"
    elif [ "$day_week" != "*" ]; then
      local day_names=("Sunday" "Monday" "Tuesday" "Wednesday" "Thursday" "Friday" "Saturday")
      echo "Weekly on ${day_names[$day_week]} at $(printf '%02d:%02d' $hour $minute)"
    else
      echo "Custom schedule"
    fi

    echo "  Command: $command"
    echo
  done <<< "$tasks"

  echo "=========================================="
  echo
}

# Main menu loop
while true; do
  echo "Task Scheduler"
  echo "1. List scheduled tasks"
  echo "2. Add a task"
  echo "3. Remove a task"
  echo "4. Preview tasks with explanations"
  echo "5. Exit"
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
      if ! list_tasks; then
        echo "Warning: An error occurred while listing tasks."
        echo
      fi
      ;;
    2)
      if ! add_task; then
        echo "Warning: Task was not added."
        echo
      fi
      ;;
    3)
      if ! remove_task; then
        echo "Warning: Task was not removed."
        echo
      fi
      ;;
    4)
      if ! preview_tasks; then
        echo "Warning: An error occurred while previewing tasks."
        echo
      fi
      ;;
    5)
      echo "Exiting Task Scheduler. Goodbye!"
      exit 0
      ;;
    *)
      echo "Error: Invalid choice '$choice'. Please enter a number between 1 and 5."
      echo
      ;;
  esac
done