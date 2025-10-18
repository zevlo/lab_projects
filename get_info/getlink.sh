#!/bin/bash

# Extract link
grep -E "\[.*\]\(.+\)" "$1" | grep -vP '\!\[' | grep -oP '\[\K[^\]]+(?=\]\([^\)]+\))' > "links.txt"
grep -E "\[.*\]\(.+\)" "$1" | grep -vP '\!\[' | grep -oP '\]\(\K[^\)]+(?=\))' > "urls.txt"

# Merge links and URLs
paste -d ' ' links.txt urls.txt

# Clean up temporary files
rm links.txt urls.txt
