# Camera Troubleshooting Guide

If you get "No camera found" or "device busy" errors, follow these steps:

## Quick Fix

1. **Release the camera:**
   ```bash
   ./release_camera.sh
   ```

2. **Close any file manager windows** that show the camera folder

3. **If still not working**, physically disconnect and reconnect the USB cable

4. **Turn the camera off and on** (this resets the USB connection)

## Common Issues

### "No camera found" error

**Causes:**
- Camera is mounted as a filesystem (file manager has it open)
- Webcam stream is still running
- USB connection issue
- Camera is in wrong mode

**Solutions:**

1. Stop webcam stream:
   ```bash
   ./stop_canon_webcam.sh
   ```

2. Release camera:
   ```bash
   ./release_camera.sh
   ```

3. Close file manager (Nautilus, Nemo, Thunar, etc.)

4. Check camera mode - should be in **P, M, Av, Tv, or Movie mode** (not Auto mode)

5. Disconnect/reconnect USB cable

### "Device or resource busy" error

This means another process is using the camera.

**Solution:**
```bash
# Kill all processes
./release_camera.sh

# Or manually:
pkill -f gvfsd-gphoto2
pkill -f "gphoto2.*capture-movie"
systemctl --user stop gvfs-gphoto2-volume-monitor.service
```

### Downloads not working

If downloads fail but camera is detected:

1. **Check camera storage:** Make sure there are photos on the camera
   ```bash
   gphoto2 --list-files
   ```

2. **Try downloading one file first:**
   ```bash
   gphoto2 --get-file --filename ~/test.jpg
   ```

3. **Check camera mode:** Should be in P/M/Av/Tv mode for full functionality

4. **Check USB cable:** Use a data-capable USB cable (not charging-only)

## Camera Mode Settings

For best results with gphoto2, set your camera to:
- **P (Program)** - Full control
- **M (Manual)** - Full control
- **Av (Aperture Priority)** - Full control
- **Tv (Shutter Priority)** - Full control
- **Movie Mode** - For video/webcam

**Avoid:**
- Auto mode - May limit functionality
- Scene modes - May not work with remote control

## Testing Camera Connection

Test if camera is properly accessible:

```bash
# 1. Release camera
./release_camera.sh

# 2. Check detection
gphoto2 --auto-detect

# 3. Check capabilities
gphoto2 --abilities

# 4. List files
gphoto2 --list-files

# 5. Test single download
gphoto2 --get-file --filename ~/test_photo.%C
```

## Preventing Future Issues

To prevent the file manager from auto-mounting the camera:

1. **Disable auto-mount** (optional):
   - Settings → Removable Media → Uncheck "Auto-open files"

2. **Always release camera** before use:
   ```bash
   ./release_camera.sh
   ```

3. **Use the scripts** - They automatically release the camera before use

## Still Not Working?

1. Check USB connection:
   ```bash
   lsusb | grep -i canon
   ```

2. Check dmesg for USB errors:
   ```bash
   dmesg | tail -20 | grep -i usb
   ```

3. Try different USB port

4. Try different USB cable

5. Restart camera (turn off and on)

6. Check gphoto2 version:
   ```bash
   gphoto2 --version
   ```

