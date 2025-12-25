#!/bin/bash
# Tethered Shooting - Capture photos directly to computer
# Photos are saved automatically as you shoot

set -e

OUTPUT_DIR="$HOME/Pictures/canon_tethered"
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
    echo "Make sure webcam stream is stopped: ./stop_canon_webcam.sh"
    exit 1
fi

echo "=========================================="
echo "Canon EOS Tethered Shooting"
echo "=========================================="
echo ""
echo "Photos will be saved to: $OUTPUT_DIR"
echo ""
echo "This will:"
echo "  1. Capture photos when you press the shutter on camera"
echo "  2. Automatically download them to your computer"
echo "  3. Show preview information"
echo ""
echo "Press Ctrl+C to stop tethered shooting"
echo ""
echo "Starting tethered shooting..."
echo ""

# Capture and download photos as they're taken
gphoto2 --capture-tethered \
    --filename "$OUTPUT_DIR/canon_%Y%m%d_%H%M%S.%C" \
    --hook-script="$HOME/canon_hook_script.sh" 2>&1 | \
    while IFS= read -r line; do
        if echo "$line" | grep -q "Saving file"; then
            FILENAME=$(echo "$line" | grep -oP 'Saving file as \K[^\s]+')
            echo "[$(date '+%H:%M:%S')] Captured: $FILENAME"
            
            # Optional: Open image in default viewer
            # xdg-open "$FILENAME" 2>/dev/null &
        fi
        echo "$line"
    done

