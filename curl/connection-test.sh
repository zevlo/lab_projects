#!/bin/bash

echo "Testing server connectivity..."

for site in google.com example.com github.com nonexistent-site.xyz; do
  echo -n "Testing $site: "

  # Use curl with a 5-second timeout
  status_code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "https://$site" 2> /dev/null)

  if [ $? -eq 0 ] && [ "$status_code" -lt 400 ]; then
    echo "OK (Status: $status_code)"
  else
    echo "Failed (Status: $status_code)"
  fi
done

echo "Testing complete!"
