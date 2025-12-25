# Canon EOS Rebel T7 Webcam Setup

This guide helps you use your Canon EOS Rebel T7 (DS126741) as a webcam on Linux using open-source tools.

## Quick Start

1. **Install dependencies:**
   ```bash
   sudo ./setup_canon_webcam.sh
   ```

2. **Start the webcam:**
   ```bash
   ./start_canon_webcam.sh
   ```

3. **Use it in your applications:**
   - Select `/dev/video2` as your video input in Zoom, Teams, Discord, OBS, etc.

4. **Stop the webcam:**
   ```bash
   ./stop_canon_webcam.sh
   ```

## What These Scripts Do

### setup_canon_webcam.sh
- Installs `gphoto2` (camera control)
- Installs `v4l2loopback` (creates virtual video device)
- Installs `ffmpeg` (video streaming)
- Loads the kernel module to create `/dev/video2`

### start_canon_webcam.sh
- Unmounts the camera from the filesystem (if mounted)
- Streams video from the camera to `/dev/video2`
- Runs in the background (PID saved to `~/.canon_webcam.pid`)

### stop_canon_webcam.sh
- Stops the webcam stream
- Cleans up processes and PID file

## Making It Permanent (Optional)

To automatically load the v4l2loopback module on boot:

```bash
echo 'v4l2loopback' | sudo tee -a /etc/modules
echo 'options v4l2loopback video_nr=2 card_label="Canon_EOS_Rebel_T7" exclusive_caps=1' | sudo tee /etc/modprobe.d/v4l2loopback.conf
```

## Troubleshooting

### Camera not detected
- Make sure the camera is connected via USB
- Try disconnecting and reconnecting
- Check with: `gphoto2 --auto-detect`

### Video device doesn't exist
- Load the module manually: `sudo modprobe v4l2loopback video_nr=2 card_label="Canon_EOS_Rebel_T7" exclusive_caps=1`

### Camera is mounted as filesystem
- The start script tries to unmount it automatically
- If it fails, manually unmount: `gvfs-mount -u gphoto2://`

### Poor performance
- Make sure no other applications are accessing the camera
- Try closing file managers that might have the camera open
- Check system resources: `top` or `htop`

### Camera won't stream
- Some Canon models need to be in "Movie Mode" or have Live View enabled
- Check camera settings
- Try turning the camera off and on

## Camera Settings Recommendations

- Set camera to **Manual (M) mode** or **Movie mode**
- Enable **Live View** if available
- Adjust exposure settings as needed
- Some cameras may overheat during extended use - monitor temperature

## Using in Applications

### Zoom
1. Start webcam: `./start_canon_webcam.sh`
2. Open Zoom → Settings → Video
3. Select "Canon_EOS_Rebel_T7" or `/dev/video2` as camera

### OBS Studio
1. Start webcam: `./start_canon_webcam.sh`
2. Add Source → Video Capture Device
3. Device: `/dev/video2` or "Canon_EOS_Rebel_T7"

### Discord/Teams
- Select the virtual camera device in video settings
- Look for "Canon_EOS_Rebel_T7" or `/dev/video2`

## Notes

- The camera must be connected via USB
- The camera will be unmounted from the filesystem while streaming
- This uses open-source tools - no proprietary Canon software required
- Compatible with Canon EOS Rebel T7 and many other Canon DSLR cameras


