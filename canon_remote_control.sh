#!/bin/bash
# Canon EOS Remote Control - Open Source EOS Utility Alternative
# Control your camera settings and take photos remotely

set -e

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
    echo "Current camera detection:"
    gphoto2 --auto-detect 2>&1
    exit 1
fi

echo "=========================================="
echo "Canon EOS Remote Control"
echo "=========================================="
echo ""

# Show current camera settings
echo "Current Camera Settings:"
echo "----------------------"
gphoto2 --get-config iso 2>&1 | grep Current || true
gphoto2 --get-config aperture 2>&1 | grep Current || true
gphoto2 --get-config shutterspeed 2>&1 | grep Current || true
gphoto2 --get-config whitebalance 2>&1 | grep Current || true

echo ""
echo "Available Commands:"
echo "  1) Take Photo"
echo "  2) Set ISO"
echo "  3) Set Aperture"
echo "  4) Set Shutter Speed"
echo "  5) Download Last Photo"
echo "  6) Download All Photos"
echo "  7) List Available Settings"
echo "  8) View Live Settings (Real-time)"
echo "  q) Quit"
echo ""

while true; do
    read -p "Select option: " choice
    
    case $choice in
        1)
            echo "Taking photo..."
            FILENAME=$(gphoto2 --capture-image-and-download --filename ~/Pictures/canon_%Y%m%d_%H%M%S.%C 2>&1 | grep -oP 'Saving file as \K[^\s]+' || echo "captured_image.jpg")
            echo "Photo captured: $FILENAME"
            ;;
        2)
            echo "Available ISO values:"
            gphoto2 --get-config iso 2>&1 | grep -E "Choice:|Current:" | head -20
            read -p "Enter ISO value: " iso_val
            gphoto2 --set-config iso="$iso_val" 2>&1 | grep -v "^#"
            echo "ISO set to: $iso_val"
            ;;
        3)
            echo "Available Aperture values:"
            gphoto2 --get-config aperture 2>&1 | grep -E "Choice:|Current:" | head -20
            read -p "Enter Aperture (e.g., 5.6): " aperture_val
            gphoto2 --set-config aperture="$aperture_val" 2>&1 | grep -v "^#"
            echo "Aperture set to: $aperture_val"
            ;;
        4)
            echo "Available Shutter Speed values:"
            gphoto2 --get-config shutterspeed 2>&1 | grep -E "Choice:|Current:" | head -20
            read -p "Enter Shutter Speed (e.g., 1/125): " shutter_val
            gphoto2 --set-config shutterspeed="$shutter_val" 2>&1 | grep -v "^#"
            echo "Shutter Speed set to: $shutter_val"
            ;;
        5)
            echo "Downloading last photo..."
            mkdir -p ~/Pictures/canon_downloads
            OUTPUT=$(gphoto2 --get-file --filename ~/Pictures/canon_downloads/last_image.%C 2>&1)
            if echo "$OUTPUT" | grep -q "Saving file\|New file"; then
                echo "$OUTPUT" | grep -E "Saving file|New file"
                echo "Downloaded to ~/Pictures/canon_downloads/"
            else
                echo "Error downloading file. Full output:"
                echo "$OUTPUT"
            fi
            ;;
        6)
            echo "Downloading all photos from camera..."
            mkdir -p ~/Pictures/canon_downloads
            
            # First, check how many files exist
            FILE_LIST=$(gphoto2 --list-files 2>&1)
            FILE_COUNT=$(echo "$FILE_LIST" | grep -c "IMG_\|MVI_" || echo "0")
            
            if [ "$FILE_COUNT" -eq 0 ]; then
                echo "No files found on camera."
                echo "Camera listing:"
                echo "$FILE_LIST"
            else
                echo "Found $FILE_COUNT file(s) on camera. Downloading..."
                OUTPUT=$(gphoto2 --get-all-files --force-overwrite --filename ~/Pictures/canon_downloads/%n.%C 2>&1)
                if echo "$OUTPUT" | grep -q "Saving file\|New file"; then
                    echo "$OUTPUT" | grep -E "Saving file|New file"
                    echo ""
                    echo "Downloaded to ~/Pictures/canon_downloads/"
                    echo "Files downloaded: $(ls -1 ~/Pictures/canon_downloads/ 2>/dev/null | wc -l)"
                else
                    echo "Error downloading files. Output:"
                    echo "$OUTPUT"
                fi
            fi
            ;;
        7)
            echo "All available camera configurations:"
            gphoto2 --list-config 2>&1 | grep -E "^/[a-z]" | head -30
            ;;
        8)
            echo "Live Settings Monitor (Press Ctrl+C to stop):"
            while true; do
                clear
                echo "=== Live Camera Settings ==="
                echo ""
                gphoto2 --get-config iso 2>&1 | grep Current || echo "ISO: N/A"
                gphoto2 --get-config aperture 2>&1 | grep Current || echo "Aperture: N/A"
                gphoto2 --get-config shutterspeed 2>&1 | grep Current || echo "Shutter: N/A"
                gphoto2 --get-config whitebalance 2>&1 | grep Current || echo "WB: N/A"
                gphoto2 --get-config exposurecompensation 2>&1 | grep Current || echo "Exposure: N/A"
                echo ""
                echo "Last updated: $(date '+%H:%M:%S')"
                sleep 2
            done
            ;;
        q|Q)
            echo "Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
    echo ""
done

