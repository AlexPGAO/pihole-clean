Pi-hole Log Cleanup Script
A small Bash script that compresses older Pi-hole log files and deletes older archived logs to help reduce SD card wear on Raspberry Pi systems.

Usage

  chmod +x pihole-clean.sh
  
   sudo ./pihole-clean.sh

What it does
  Compresses .log files older than 1 day
  Deletes .gz log files older than the set retention period
  Removes old FTL log rotations

  
Configuration

Edit this line in the script to change how long compressed logs are kept:

DAYS_TO_KEEP=7
