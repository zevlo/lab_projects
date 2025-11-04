#!/bin/bash

# This script automates the batch creation and deletion of teacher and student users.

# --- Parameter Validation ---

# 1. Check for the correct number of arguments (must be 4).
if [ "$#" -ne 4 ]; then
  echo "parameter error"
  exit 1
fi

# Assign arguments to readable variable names
OPERATION=$1
TEACHER_NAME=$2
STUDENT_PREFIX=$3
STUDENT_COUNT=$4

# 2. Validate the student count. It must be an integer between 1 and 10.
# Check if it's a number and within the range [1, 10].
if ! [[ "$STUDENT_COUNT" =~ ^[0-9]+$ ]] || [ "$STUDENT_COUNT" -lt 1 ] || [ "$STUDENT_COUNT" -gt 10 ]; then
  echo "parameter error"
  exit 1
fi

# 3. Validate the student name prefix. It must contain only lowercase letters.
if ! [[ "$STUDENT_PREFIX" =~ ^[a-z]+$ ]]; then
  echo "parameter error"
  exit 1
fi

# --- Helper Function ---

# Function to generate a random 6-digit password.
generate_password() {
  # shuf is a command that generates random permutations.
  # -i specifies an input range, -n specifies the number of lines to output.
  shuf -i 100000-999999 -n 1
}

# --- Main Logic ---

# Check the operation type provided as the first argument.
if [ "$OPERATION" == "add" ]; then
  # --- Add Users ---

  # Add the teacher user
  # First, check if the user already exists using 'id -u'.
  if ! id -u "$TEACHER_NAME" &> /dev/null; then
    # If user does not exist, create them.
    # -m creates the home directory.
    # -s sets the default shell to /bin/zsh.
    sudo useradd -m -s /bin/zsh "$TEACHER_NAME"
    # Add the teacher to the 'sudo' group for administrative privileges.
    sudo usermod -aG sudo "$TEACHER_NAME"
    # Generate a password and print the credentials.
    password=$(generate_password)
    echo "$TEACHER_NAME:$password"
  else
    # If user already exists, print asterisks for the password.
    echo "$TEACHER_NAME:******"
  fi

  # Add student users using a for loop.
  for ((i = 1; i <= STUDENT_COUNT; i++)); do
    username="${STUDENT_PREFIX}${i}"
    # Check if the student user already exists.
    if ! id -u "$username" &> /dev/null; then
      # If not, create the user.
      sudo useradd -m -s /bin/zsh "$username"
      # Generate a password and print credentials.
      password=$(generate_password)
      echo "$username:$password"
    else
      # If user exists, print asterisks.
      echo "$username:******"
    fi
  done

elif [ "$OPERATION" == "del" ]; then
  # --- Delete Users ---

  # Delete the teacher user.
  # -r removes the home directory.
  # -f forces removal even if the user is logged in.
  # Redirect output to /dev/null to suppress messages.
  sudo userdel -rf "$TEACHER_NAME" &> /dev/null

  # Delete student users using a for loop.
  for ((i = 1; i <= STUDENT_COUNT; i++)); do
    username="${STUDENT_PREFIX}${i}"
    sudo userdel -rf "$username" &> /dev/null
  done
fi
