#!/bin/bash

# Server Monitoring Script
# This script checks the availability and performance of specified servers

# Define colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to check server status
check_server() {
  local url=$1
  local timeout=5

  echo -e "\n${YELLOW}Testing $url:${NC}"

  # Test connection and get status code
  status_code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout $timeout "$url" 2> /dev/null)

  if [ "$status_code" -eq 200 ]; then
    echo -e "${GREEN}✓ Status: $status_code (OK)${NC}"
  elif [ "$status_code" -ge 100 ] && [ "$status_code" -lt 400 ]; then
    echo -e "${GREEN}✓ Status: $status_code (Success/Redirect)${NC}"
  elif [ "$status_code" -ge 400 ] && [ "$status_code" -lt 500 ]; then
    echo -e "${RED}✗ Status: $status_code (Client Error)${NC}"
  elif [ "$status_code" -ge 500 ]; then
    echo -e "${RED}✗ Status: $status_code (Server Error)${NC}"
  else
    echo -e "${RED}✗ Status: Connection failed${NC}"
  fi

  # Measure response time if connection successful
  if [ "$status_code" -gt 0 ]; then
    response_time=$(curl -s -o /dev/null -w "%{time_total}" --connect-timeout $timeout "$url" 2> /dev/null)
    echo -e "• Response time: ${response_time}s"

    # Get server headers
    echo "• Server headers:"
    curl -s -I --connect-timeout $timeout "$url" | grep -E 'Server:|Content-Type:|Date:' | sed 's/^/  /'
  fi
}

# Main function
main() {
  echo -e "${YELLOW}===== Server Connectivity Monitor =====${NC}"
  echo "Started at: $(date)"

  # List of servers to monitor
  servers=(
    "https://www.google.com"
    "https://www.github.com"
    "https://www.example.com"
    "https://httpbin.org/status/404" # This will return a 404 status
    "https://httpbin.org/status/500" # This will return a 500 status
  )

  # Check each server
  for server in "${servers[@]}"; do
    check_server "$server"
  done

  echo -e "\n${YELLOW}===== Monitoring Complete =====${NC}"
  echo "Finished at: $(date)"
}

# Run the main function
main
