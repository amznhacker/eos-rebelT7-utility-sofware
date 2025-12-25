#!/bin/bash
# Bulk download all photos from camera
# Alternative to EOS Utility's image transfer

set -e

OUTPUT_DIR="$HOME/Pictures/canon_downloads_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTPUT_DIR"

# Stop any processes that might be using the camera
echo "Releasing camera from other processes..."
systemctl --user stop gvfs-gphoto2-volume-monitor.service 2>/dev/null || true
pkill -f gvfsd-gphoto2 2>/dev/null || true
pkill -f "gphoto2.*capture-movie" 2>/dev/null || true
pkill -f "ffmpeg.*video2" 2>/dev/null || true
gio mount -u gphoto2:// 2>/dev/null || gvfs-mount -u gphoto2:// 2>/dev/null || true
sleep 2

# Check if camera is available
if ! gphoto2 --auto-detect 2>&1 | grep -q "Canon\|Canon EOS"; then
    echo "Error: Canon camera not detected."
    echo ""
    echo "Troubleshooting:"
    echo "  1. Make sure camera is connected via USB and turned ON"
    echo "  2. Stop webcam stream: ./stop_canon_webcam.sh"
    echo "  3. Close any file manager windows showing the camera"
    echo "  4. Try disconnecting and reconnecting the USB cable"
    echo ""
    echo "Current detection:"
    gphoto2 --auto-detect 2>&1
    exit 1
fi

echo "=========================================="
echo "Canon EOS Bulk Image Download"
echo "=========================================="
echo ""
echo "Downloading all photos to: $OUTPUT_DIR"
echo ""

# List files first
echo "Photos on camera:"
FILE_LIST=$(gphoto2 --list-files 2>&1)
echo "$FILE_LIST"

FILE_COUNT=$(echo "$FILE_LIST" | grep -c "IMG_\|MVI_" || echo "0")

if [ "$FILE_COUNT" -eq 0 ]; then
    echo ""
    echo "No files found on camera to download."
    exit 0
fi

echo ""
echo "Found approximately $FILE_COUNT file(s) on camera."
read -p "Continue with download? (y/n) " confirm

if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "Downloading..."

# Download all files, preserving original filenames
OUTPUT=$(gphoto2 --get-all-files \
    --force-overwrite \
    --filename "$OUTPUT_DIR/%n.%C" 2>&1)

if echo "$OUTPUT" | grep -q "Saving file\|New file"; then
    echo "$OUTPUT" | grep -E "Saving file|New file"
    echo ""
    echo "Download complete!"
    echo "Files saved to: $OUTPUT_DIR"
    
    # Show summary
    DOWNLOADED_COUNT=$(find "$OUTPUT_DIR" -type f 2>/dev/null | wc -l)
    TOTAL_SIZE=$(du -sh "$OUTPUT_DIR" 2>/dev/null | cut -f1 || echo "0")
    
    echo "Total files downloaded: $DOWNLOADED_COUNT"
    echo "Total size: $TOTAL_SIZE"
else
    echo "Error during download:"
    echo "$OUTPUT"
    echo ""
    echo "This might be due to:"
    echo "  - Camera communication error"
    echo "  - USB connection issue"
    echo "  - Camera being used by another process"
    echo ""
    echo "Try:"
    echo "  1. Disconnect and reconnect USB cable"
    echo "  2. Make sure camera is in P/M/Av/Tv mode (not Auto)"
    echo "  3. Check camera screen for any errors"
fi

