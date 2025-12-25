#!/bin/bash
# Setup script for Canon EOS Rebel T7 as webcam
# This script installs required dependencies

set -e

echo "=========================================="
echo "Canon EOS Rebel T7 Webcam Setup"
echo "=========================================="
echo ""

# Check if running as root for package installation
if [ "$EUID" -eq 0 ]; then 
    echo "Running as root. Installing packages..."
    
    # Update package list
    apt-get update
    
    # Install gphoto2
    if ! command -v gphoto2 &> /dev/null; then
        echo "Installing gphoto2..."
        apt-get install -y gphoto2
    else
        echo "gphoto2 is already installed."
    fi
    
    # Install v4l2loopback-dkms and utils
    if ! modinfo v4l2loopback &> /dev/null; then
        echo "Installing v4l2loopback..."
        apt-get install -y v4l2loopback-dkms v4l2loopback-utils
    else
        echo "v4l2loopback is already installed."
    fi
    
    # Install ffmpeg
    if ! command -v ffmpeg &> /dev/null; then
        echo "Installing ffmpeg..."
        apt-get install -y ffmpeg
    else
        echo "ffmpeg is already installed."
    fi
    
    # Load v4l2loopback module
    echo "Loading v4l2loopback kernel module..."
    modprobe v4l2loopback video_nr=2 card_label="Canon_EOS_Rebel_T7" exclusive_caps=1
    
    echo ""
    echo "Setup complete!"
    echo ""
    echo "To make the module load automatically on boot, run:"
    echo "  echo 'v4l2loopback' | sudo tee -a /etc/modules"
    echo "  echo 'options v4l2loopback video_nr=2 card_label=\"Canon_EOS_Rebel_T7\" exclusive_caps=1' | sudo tee /etc/modprobe.d/v4l2loopback.conf"
    
else
    echo "This script needs root privileges to install packages."
    echo "Please run: sudo $0"
    exit 1
fi


