#!/bin/bash
# Release camera from file manager and other processes
# Use this before running any gphoto2 commands if you get "device busy" errors

echo "Releasing camera from all processes..."

# Stop gvfs services
systemctl --user stop gvfs-gphoto2-volume-monitor.service 2>/dev/null || true

# Kill gvfs processes
pkill -f gvfsd-gphoto2 2>/dev/null || true

# Stop webcam stream if running
if [ -f "$HOME/.canon_webcam.pid" ]; then
    PID=$(cat "$HOME/.canon_webcam.pid")
    if ps -p "$PID" > /dev/null 2>&1; then
        echo "Stopping webcam stream..."
        kill "$PID" 2>/dev/null || true
        pkill -f "gphoto2.*capture-movie" 2>/dev/null || true
        pkill -f "ffmpeg.*video2" 2>/dev/null || true
        rm -f "$HOME/.canon_webcam.pid"
    fi
fi

# Unmount camera
gio mount -u gphoto2:// 2>/dev/null || gvfs-mount -u gphoto2:// 2>/dev/null || true

# Wait for processes to release
sleep 2

# Verify camera is accessible
echo ""
echo "Checking camera status..."
if gphoto2 --auto-detect 2>&1 | grep -q "Canon\|Canon EOS"; then
    echo "✓ Camera is now accessible!"
    gphoto2 --auto-detect 2>&1 | grep -E "Model|Canon"
else
    echo "✗ Camera still not detected."
    echo ""
    echo "Try:"
    echo "  1. Disconnect and reconnect USB cable"
    echo "  2. Turn camera off and on"
    echo "  3. Close any file manager windows"
fi

