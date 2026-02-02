# 🧹 Pi-hole Log Cleanup Script

<div align="center">

![Bash](https://img.shields.io/badge/bash-5.0+-green.svg)
![Platform](https://img.shields.io/badge/platform-raspberry%20pi%20%7C%20linux-lightgrey.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Pi-hole](https://img.shields.io/badge/pi--hole-compatible-red.svg)

**Automated log management for Pi-hole to reduce SD card wear and save space**

[Features](#-features) • [Installation](#-installation) • [Usage](#-usage) • [Automation](#-automation)

</div>

---

## 🎯 Overview

A lightweight Bash script that automatically manages Pi-hole logs by compressing old logs and removing outdated entries. Designed to reduce SD card wear on Raspberry Pi systems and prevent log files from consuming excessive storage space.

### Why This Script?

- 💾 **Prevent SD Card Wear** - Reduces constant write operations that can degrade SD cards
- 📦 **Save Storage Space** - Compresses logs and removes old entries automatically
- 🔄 **Set and Forget** - Schedule with cron for fully automated log management
- ⚡ **Fast & Safe** - Uses `set -euo pipefail` for error handling and safe execution

---

## ✨ Features

### Automated Log Management
- ✅ **Automatic Compression** - Compresses `.log` files older than 1 day using gzip
- ✅ **Automatic Cleanup** - Removes compressed logs older than 7 days (configurable)
- ✅ **FTL Log Cleanup** - Removes old FTL (Faster Than Light) daemon logs
- ✅ **Safe Execution** - Error handling prevents partial cleanup or corruption

### How It Works

```
┌─────────────────────────┐
│   Pi-hole Logs          │
│   /var/log/pihole/      │
└──────────┬──────────────┘
           │
           │ Script runs (manual or cron)
           ↓
┌─────────────────────────┐
│  Find logs > 1 day old  │  ← Compress with gzip
│  *.log → *.log.gz       │     (saves ~90% space)
└──────────┬──────────────┘
           │
           ↓
┌─────────────────────────┐
│  Find logs > 7 days old │  ← Delete compressed logs
│  Remove *.gz files      │     and old FTL logs
└─────────────────────────┘
```

**Result:** Keeps recent logs accessible, compresses older logs for space savings, removes ancient logs to prevent storage bloat.

---

## 🚀 Installation

### Prerequisites

```bash
# Pi-hole must be installed
pihole status

# Verify log directory exists
ls -lh /var/log/pihole/
```

### Download Script

```bash
# Clone repository
git clone https://github.com/AlexPGAO/pihole-log-cleanup.git
cd pihole-log-cleanup

# Or download directly
wget https://raw.githubusercontent.com/AlexPGAO/pihole-log-cleanup/main/pihole-clean.sh
```

### Make Executable

```bash
chmod +x pihole-clean.sh
```

---

## ⚡ Quick Start

### Run Manually

```bash
# Run with sudo (required for /var/log/ access)
sudo ./pihole-clean.sh
```

**Expected output:**
```
Don't mind me just cleaning your Pi-hole logs... you said uninstall pihole right? JK, wiping the past 7 days and compressing the rest
Cleanup complete.
```

### Test First (Dry Run)

Before scheduling, verify what the script will do:

```bash
# See what files would be compressed (older than 1 day)
find /var/log/pihole -type f -name "*.log" -mtime +1

# See what files would be deleted (older than 7 days)
find /var/log/pihole -type f -name "*.gz" -mtime +7
find /var/log/pihole -type f -name "FTL.log.*" -mtime +7
```

---

## ⚙️ Configuration

### Adjust Retention Period

Edit the script to change how long logs are kept:

```bash
nano pihole-clean.sh
```

**Modify this line:**
```bash
DAYS_TO_KEEP=7  # Change to desired number of days
```

**Common configurations:**
- `DAYS_TO_KEEP=3` - Keep 3 days (minimal storage)
- `DAYS_TO_KEEP=7` - Keep 7 days (default, recommended)
- `DAYS_TO_KEEP=14` - Keep 14 days (more history)
- `DAYS_TO_KEEP=30` - Keep 30 days (maximum retention)

### Adjust Compression Threshold

To change when logs get compressed:

```bash
# Line 17: Change compression age
find "$LOG_DIR" -type f -name "*.log" -mtime +1 -exec gzip {} \;
#                                              ↑
#                                    Change +1 to +2, +3, etc.
```

---

## 🔄 Automation (Recommended)

### Schedule with Cron

Run automatically every day at 3 AM:

```bash
# Edit crontab
sudo crontab -e

# Add this line:
0 3 * * * /path/to/pihole-clean.sh >> /var/log/pihole-cleanup.log 2>&1
```

**Common schedules:**
```bash
# Daily at 3 AM
0 3 * * * /home/pi/pihole-clean.sh

# Weekly on Sunday at 2 AM
0 2 * * 0 /home/pi/pihole-clean.sh

# Every 12 hours
0 */12 * * * /home/pi/pihole-clean.sh

# Monthly on the 1st at midnight
0 0 1 * * /home/pi/pihole-clean.sh
```

### Verify Cron Job

```bash
# List current cron jobs
sudo crontab -l

# Check cron logs
grep CRON /var/log/syslog | tail -20

# View cleanup log (if logging enabled)
cat /var/log/pihole-cleanup.log
```

---

## 💻 Usage Examples

### Basic Usage

```bash
# Run cleanup
sudo ./pihole-clean.sh
```

### Check Space Saved

```bash
# Before cleanup
du -sh /var/log/pihole/

# After cleanup
du -sh /var/log/pihole/

# Detailed breakdown
du -h /var/log/pihole/* | sort -rh
```

### Manual Compression

```bash
# Compress a specific log
sudo gzip /var/log/pihole/pihole.log.1

# Compress all uncompressed logs
sudo gzip /var/log/pihole/*.log
```

### View Compressed Logs

```bash
# View compressed log without extracting
zcat /var/log/pihole/pihole.log.1.gz | less

# Search in compressed log
zgrep "blocked" /var/log/pihole/pihole.log.1.gz

# Extract compressed log
gunzip /var/log/pihole/pihole.log.1.gz
```

---

## 📊 What Gets Cleaned

### File Types Managed

| File Type | Age Threshold | Action | Result |
|-----------|---------------|--------|--------|
| `*.log` | > 1 day | Compress | `.log` → `.log.gz` |
| `*.log.gz` | > 7 days | Delete | Removed |
| `FTL.log.*` | > 7 days | Delete | Removed |

### Example Before/After

**Before cleanup:**
```
/var/log/pihole/
├── pihole.log          (5.2 MB)   ← Today
├── pihole.log.1        (4.8 MB)   ← 2 days old
├── pihole.log.2        (4.9 MB)   ← 3 days old
├── pihole.log.3.gz     (512 KB)   ← 5 days old
├── pihole.log.4.gz     (498 KB)   ← 8 days old  ← WILL BE DELETED
├── FTL.log             (2.1 MB)
└── FTL.log.1           (1.9 MB)   ← 10 days old ← WILL BE DELETED

Total: 19.9 MB
```

**After cleanup:**
```
/var/log/pihole/
├── pihole.log          (5.2 MB)   ← Kept (current)
├── pihole.log.1.gz     (489 KB)   ← Compressed
├── pihole.log.2.gz     (502 KB)   ← Compressed
├── pihole.log.3.gz     (512 KB)   ← Kept (< 7 days)
├── FTL.log             (2.1 MB)   ← Kept (current)

Total: 8.8 MB (saved 11.1 MB)
```

---

## 🔧 Troubleshooting

### Permission Denied

```bash
# Error: Permission denied
# Fix: Run with sudo
sudo ./pihole-clean.sh
```

### Script Won't Execute

```bash
# Error: Permission denied or "command not found"
# Fix: Make script executable
chmod +x pihole-clean.sh

# Verify permissions
ls -l pihole-clean.sh
# Should show: -rwxr-xr-x
```

### No Files Found

```bash
# Check if Pi-hole logs exist
ls -lh /var/log/pihole/

# Verify Pi-hole is running
pihole status

# Check Pi-hole logging is enabled
pihole -c
```

### Cron Job Not Running

```bash
# Check cron service is running
sudo systemctl status cron

# Start cron if stopped
sudo systemctl start cron

# View cron execution log
grep pihole-clean /var/log/syslog

# Test script manually first
sudo /path/to/pihole-clean.sh
```

### Logs Still Growing

```bash
# Check Pi-hole query volume
pihole -c -e

# Reduce logging if needed
pihole -l off  # Disable logging
pihole -l on   # Re-enable logging

# Consider reducing DAYS_TO_KEEP
nano pihole-clean.sh
# Change DAYS_TO_KEEP=7 to smaller value
```

---

## 🎓 Technical Details

### How Compression Works

- **gzip compression** - Typically achieves 90%+ compression ratio for text logs
- **Preserves timestamp** - Compressed files retain original modification date
- **Safe operation** - Uses `-exec` to compress files individually (prevents errors from affecting other files)

### Script Safety Features

```bash
set -euo pipefail
```

- `set -e` - Exit immediately if any command fails
- `set -u` - Treat unset variables as errors
- `set -o pipefail` - Return exit code of first failed command in pipeline

### Disk Space Savings

**Typical log file sizes:**
- Uncompressed log: 5-10 MB per day
- Compressed log: 500-1000 KB per day
- **Savings: ~90% space reduction**

**Example calculations:**
```
Without cleanup (30 days): ~150-300 MB
With cleanup (7 days):     ~15-30 MB
Space saved:               ~135-270 MB
```

On a 16GB SD card, this script can save significant space and reduce write cycles.

---

## 🤝 Contributing

Contributions welcome! Ideas for enhancement:

- [ ] Add email notifications when cleanup completes
- [ ] Generate cleanup report with statistics
- [ ] Support for custom log directories
- [ ] Archive old logs to external storage
- [ ] Integration with Pi-hole web interface
- [ ] Configurable compression levels

---

## 📄 License

MIT License - free to use, modify, and distribute.

---

## 🔗 Links

- **Repository:** https://github.com/AlexPGAO/pihole-log-cleanup
- **Pi-hole Documentation:** https://docs.pi-hole.net/
- **Issues:** https://github.com/AlexPGAO/pihole-log-cleanup/issues

---

## 🙏 Acknowledgments

- Pi-hole team for the amazing network-wide ad blocking
- Raspberry Pi community for SD card optimization tips

---

<div align="center">

**[⬆ Back to Top](#-pi-hole-log-cleanup-script)**

**Author:** [AlexPGAO](https://github.com/AlexPGAO) | **Version:** 1.0 | **Status:** ✅ Active

</div>
