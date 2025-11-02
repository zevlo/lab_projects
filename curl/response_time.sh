#!/bin/bash

echo "Testing response times..."

for site in google.com bing.com baidu.com duckduckgo.com yahoo.com; do
  echo -n "$site: "
  curl -s -o /dev/null -w "%{time_total}s" "https://$site"
  echo ""
done

echo "Testing complete!"
