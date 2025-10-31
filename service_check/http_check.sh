#!/bin/bash

# URL to check
URL="http://example.com"

# Perform the HTTP request
HTTP_RESPONSE=$(curl -o /dev/null -s -w "%{http_code}" "$URL")

# Check if the HTTP response code is 200 (OK)
if [[ "$HTTP_RESPONSE" -eq 200 ]]; then
    echo "Service is up and running (HTTP $HTTP_RESPONSE)."
else
    echo "Service check failed! Received HTTP response: $HTTP_RESPONSE"
fi
