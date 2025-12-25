#!/bin/bash
# Hook script for tethered shooting
# This runs automatically when a photo is captured

# $1 = filename on camera
# $2 = filename on computer

echo "[HOOK] Photo captured: $2"
echo "[HOOK] File size: $(du -h "$2" | cut -f1)"

# Optional: You can add custom processing here
# For example:
# - Auto-rename based on metadata
# - Apply presets
# - Upload to cloud storage
# - Create backups

