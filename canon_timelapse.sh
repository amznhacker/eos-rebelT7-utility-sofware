#!/bin/bash
# Time-lapse Photography
# Take photos at regular intervals automatically

set -e

# Default values
INTERVAL=5  # seconds
COUNT=10    # number of photos
OUTPUT_DIR="$HOME/Pictures/canon_timelapse_$(date +%Y%m%d_%H%M%S)"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--interval)
            INTERVAL="$2"
            shift 2
            ;;
        -c|--count)
            COUNT="$2"
            shift 2
            ;;
        -d|--directory)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [-i INTERVAL] [-c COUNT] [-d DIRECTORY]"
            echo ""
            echo "Options:"
            echo "  -i, --interval   Time between shots in seconds (default: 5)"
            echo "  -c, --count      Number of photos to take (default: 10)"
            echo "  -d, --directory  Output directory (default: ~/Pictures/canon_timelapse_*)"
            echo ""
            echo "Example:"
            echo "  $0 -i 10 -c 60    # Take 60 photos, 10 seconds apart"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

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
echo "Canon EOS Time-lapse Photography"
echo "=========================================="
echo ""
echo "Settings:"
echo "  Interval: $INTERVAL seconds"
echo "  Count: $COUNT photos"
echo "  Output: $OUTPUT_DIR"
echo ""
echo "Estimated duration: $((INTERVAL * COUNT / 60)) minutes"
echo ""
read -p "Start time-lapse? (y/n) " confirm

if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "Starting time-lapse..."
echo "Press Ctrl+C to stop early"
echo ""

for ((i=1; i<=COUNT; i++)); do
    echo "[$i/$COUNT] $(date '+%H:%M:%S') - Capturing..."
    
    gphoto2 --capture-image-and-download \
        --filename "$OUTPUT_DIR/timelapse_%06d.%C" \
        --force-overwrite \
        --set-index="$i" 2>&1 | grep -E "Saving file|New file" || true
    
    if [ $i -lt $COUNT ]; then
        echo "  Waiting $INTERVAL seconds until next shot..."
        sleep "$INTERVAL"
    fi
done

echo ""
echo "Time-lapse complete!"
echo "Photos saved to: $OUTPUT_DIR"

# Offer to create video from images
read -p "Create video from images? (requires ffmpeg) (y/n) " create_video

if [ "$create_video" = "y" ] || [ "$create_video" = "Y" ]; then
    if command -v ffmpeg &> /dev/null; then
        VIDEO_FILE="$OUTPUT_DIR/timelapse_$(date +%Y%m%d_%H%M%S).mp4"
        echo "Creating video: $VIDEO_FILE"
        
        # Find first image to get dimensions
        FIRST_IMAGE=$(ls "$OUTPUT_DIR"/*.{jpg,JPG,cr2,CR2} 2>/dev/null | head -1)
        
        if [ -n "$FIRST_IMAGE" ]; then
            ffmpeg -framerate 10 -pattern_type glob -i "$OUTPUT_DIR/*.JPG" \
                -c:v libx264 -pix_fmt yuv420p "$VIDEO_FILE" 2>&1 | \
                grep -E "frame|Stream|Output" || true
            
            echo "Video created: $VIDEO_FILE"
        else
            echo "No images found to create video."
        fi
    else
        echo "ffmpeg not found. Skipping video creation."
    fi
fi

