#!/bin/bash
# Start Canon EOS Rebel T7 as webcam
# This script creates a virtual video device that can be used as a webcam

set -e

VIDEO_DEVICE="/dev/video2"
PIDFILE="$HOME/.canon_webcam.pid"

# Check if already running
if [ -f "$PIDFILE" ]; then
    OLD_PID=$(cat "$PIDFILE")
    if ps -p "$OLD_PID" > /dev/null 2>&1; then
        echo "Webcam stream is already running (PID: $OLD_PID)"
        echo "Use ./stop_canon_webcam.sh to stop it first"
        exit 1
    else
        rm -f "$PIDFILE"
    fi
fi

# Check if video device exists
if [ ! -e "$VIDEO_DEVICE" ]; then
    echo "Error: $VIDEO_DEVICE does not exist."
    echo "Please load the v4l2loopback module first:"
    echo "  sudo modprobe v4l2loopback video_nr=2 card_label=\"Canon_EOS_Rebel_T7\" exclusive_caps=1"
    exit 1
fi

# Check if required commands exist
if ! command -v gphoto2 &> /dev/null; then
    echo "Error: gphoto2 is not installed."
    echo "Please run: sudo ./setup_canon_webcam.sh"
    exit 1
fi

if ! command -v ffmpeg &> /dev/null; then
    echo "Error: ffmpeg is not installed."
    echo "Please run: sudo ./setup_canon_webcam.sh"
    exit 1
fi

# Stop gvfs processes that might be using the camera
echo "Stopping processes that might be using the camera..."

# Try to unmount camera if mounted via gvfs
gio mount -u gphoto2:// 2>/dev/null || gvfs-mount -u gphoto2:// 2>/dev/null || true

# Stop the gvfs-gphoto2-volume-monitor service
systemctl --user stop gvfs-gphoto2-volume-monitor.service 2>/dev/null || true

# Kill any gvfsd-gphoto2 processes that are holding the camera
pkill -f gvfsd-gphoto2 2>/dev/null || true

# Give processes time to release the device
sleep 2

# Check camera connection
echo "Checking camera connection..."
if ! gphoto2 --auto-detect | grep -q "Canon"; then
    echo "Warning: Could not detect Canon camera. Continuing anyway..."
fi

echo ""
echo "Starting webcam stream..."
echo "Camera will be available at: $VIDEO_DEVICE"
echo "Press Ctrl+C to stop, or run: ./stop_canon_webcam.sh"
echo ""

# Start the stream in background
gphoto2 --stdout --capture-movie | \
    ffmpeg -i - \
        -vcodec rawvideo \
        -pix_fmt yuv420p \
        -threads 0 \
        -f v4l2 "$VIDEO_DEVICE" \
        2>&1 | grep -v "frame=" > /tmp/canon_webcam.log &

STREAM_PID=$!
echo $STREAM_PID > "$PIDFILE"

echo "Webcam stream started (PID: $STREAM_PID)"
echo "Log file: /tmp/canon_webcam.log"
echo ""
echo "You can now use $VIDEO_DEVICE as your webcam in applications like:"
echo "  - Zoom, Teams, Discord, etc."
echo "  - OBS Studio"
echo "  - Any application that supports /dev/video2"
echo ""
echo "To stop the stream, run: ./stop_canon_webcam.sh"


