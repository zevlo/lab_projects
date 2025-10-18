#!/bin/bash

# Extract image URL
image_urls=$(grep -o "\!\[.*]\(.*\)" "$1" | sed -E "s/(\!\[.*]\()(.+)(.*\))/\2/g")

# Print image URL
echo "$image_urls"
