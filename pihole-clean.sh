#!/bin/bash

# === Pi-hole Log Cleanup Script ===
# Safely compress and remove old logs to reduce SD card wear.
#AlexPGAO v1.0

set -euo pipefail

LOG_DIR="/var/log/pihole"
DAYS_TO_KEEP=7

echo "Don't mind me just cleaning your Pi-hole logs... you said uninstall pihole right? JK, wiping the past ${DAYS_TO_KEEP}  days and compressing the rest"

# Compress any uncompressed logs older than 1 day
find "$LOG_DIR" -type f -name "*.log" -mtime +1 -exec gzip {} \;

# Remove compressed logs older than X days
find "$LOG_DIR" -type f -name "*.gz" -mtime +$DAYS_TO_KEEP -delete

# Clean FTL logs
find "$LOG_DIR" -type f -name "FTL.log.*" -mtime +$DAYS_TO_KEEP -delete

echo "Cleanup complete."
