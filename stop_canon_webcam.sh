#!/bin/bash
# Stop Canon EOS Rebel T7 webcam stream

PIDFILE="$HOME/.canon_webcam.pid"

if [ ! -f "$PIDFILE" ]; then
    echo "Webcam stream is not running (no PID file found)"
    exit 0
fi

PID=$(cat "$PIDFILE")

if ! ps -p "$PID" > /dev/null 2>&1; then
    echo "Webcam stream is not running (process not found)"
    rm -f "$PIDFILE"
    exit 0
fi

echo "Stopping webcam stream (PID: $PID)..."

# Kill the process and its children
kill -TERM "$PID" 2>/dev/null || true

# Wait a moment
sleep 1

# Force kill if still running
if ps -p "$PID" > /dev/null 2>&1; then
    echo "Force stopping..."
    kill -KILL "$PID" 2>/dev/null || true
    sleep 1
fi

# Clean up
rm -f "$PIDFILE"

# Also kill any remaining ffmpeg/gphoto2 processes related to this
pkill -f "gphoto2.*capture-movie" 2>/dev/null || true
pkill -f "ffmpeg.*video2" 2>/dev/null || true

echo "Webcam stream stopped."


