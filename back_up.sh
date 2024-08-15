#!/bin/bash

# Variables
SOURCE_DIR="/home/mouez/Downloads"          # Directory to back up
BACKUP_DIR="/media/mouez/Mouez_jb/games"  # Path to the backup directory on the external drive

# Check if the external drive is mounted
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Backup directory not found. Please check if the external drive is mounted."
    exit 1
fi

# Create the backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Perform the backup using rsync
rsync -avh --delete "$SOURCE_DIR" "$BACKUP_DIR"

# Output the result
if [ $? -eq 0 ]; then
    echo "Backup completed successfully."
else
    echo "Backup failed."
fi

