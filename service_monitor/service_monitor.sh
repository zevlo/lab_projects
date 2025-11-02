#!/bin/bash
SERVICE="nginx"
if ! pgrep -x "$SERVICE" > /dev/null; then
  echo "$SERVICE is down. Restarting..."
  systemctl start $SERVICE
else
  echo "$SERVICE is running."
fi
