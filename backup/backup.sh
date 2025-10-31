#!/bin/bash

# Backup script for the home directory
TIMESTAMP=$(date '+%Y-%m-%d_%H:%M')
DEST_DIR="$HOME/backups"
SOURCE_DIR="$HOME"

mkdir -p "$DEST_DIR"

# Save backup in DEST_DIR, and archive from SOURCE_DIR
tar -czvf "$DEST_DIR/home_backup_$TIMESTAMP.tar.gz" -C "$SOURCE_DIR" .

echo -e "\nBackup of $SOURCE_DIR completed at $DEST_DIR/home_backup_$TIMESTAMP.tar.gz\n"
