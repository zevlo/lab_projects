#!/bin/bash

# Loop through an array of names
echo "Looping through an array:"
NAMES=("Alice" "Bob" "Charlie" "David")
for name in "${NAMES[@]}"; do
  echo "Hello, $name!"
done

echo # Print an empty line for readability

# Loop through a range of numbers
echo "Looping through a range of numbers:"
for i in {1..5}; do
  echo "Number: $i"
done
