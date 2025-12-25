# EOS Rebel T7 Utility Software (Open Source)

A complete open-source alternative to Canon's proprietary EOS Utility software for the Canon EOS Rebel T7 (also known as Canon EOS 1500D). This project provides all the functionality of EOS Utility and more, using only free and open-source tools.

## 🎯 Features

### ✅ Core Features (EOS Utility Replacement)
- **Remote Camera Control** - Adjust ISO, aperture, shutter speed, white balance
- **Tethered Shooting** - Capture photos directly to your computer
- **Bulk Image Download** - Transfer all photos from camera
- **Time-lapse Photography** - Automated interval shooting with video creation
- **Live View & Settings Monitor** - Real-time camera settings display

### 🚀 Bonus Features (Not in EOS Utility!)
- **Webcam Mode** - Use your DSLR as a high-quality webcam
- **Scriptable & Automatable** - Full command-line control
- **Cross-Platform** - Works on Linux (EOS Utility doesn't!)
- **No Proprietary Software** - 100% open source

## 📋 Requirements

- **Camera:** Canon EOS Rebel T7 / EOS 1500D (may work with other Canon cameras)
- **OS:** Linux (Ubuntu/Debian recommended)
- **USB Connection:** USB cable to connect camera
- **Software:** gphoto2, v4l2loopback, ffmpeg

## 🚀 Quick Start

### 1. Installation

```bash
# Clone this repository
git clone https://github.com/yourusername/eos-rebelT7-utility-software.git
cd eos-rebelT7-utility-software

# Install dependencies (requires sudo)
sudo ./setup_canon_webcam.sh
```

This will install:
- `gphoto2` - Camera control library
- `v4l2loopback` - Virtual video device (for webcam mode)
- `ffmpeg` - Video processing

### 2. Basic Usage

#### Webcam Mode
```bash
# Start webcam stream
./start_canon_webcam.sh

# Use /dev/video2 in Zoom, OBS, Discord, etc.

# Stop webcam stream
./stop_canon_webcam.sh
```

#### Remote Camera Control
```bash
# Interactive menu for camera control
./canon_remote_control.sh
```

#### Tethered Shooting
```bash
# Capture photos directly to computer
./canon_tethered_shoot.sh
```

#### Bulk Download
```bash
# Download all photos from camera
./canon_bulk_download.sh
```

#### Time-lapse
```bash
# Take 60 photos, 10 seconds apart
./canon_timelapse.sh -i 10 -c 60
```

## 📁 Scripts Overview

| Script | Description |
|--------|-------------|
| `setup_canon_webcam.sh` | Installs all required dependencies |
| `start_canon_webcam.sh` | Starts webcam streaming to `/dev/video2` |
| `stop_canon_webcam.sh` | Stops webcam stream |
| `release_camera.sh` | Releases camera from file manager processes |
| `canon_remote_control.sh` | Interactive camera control (ISO, aperture, etc.) |
| `canon_tethered_shoot.sh` | Tethered shooting mode |
| `canon_bulk_download.sh` | Download all photos from camera |
| `canon_timelapse.sh` | Time-lapse photography with video creation |
| `canon_hook_script.sh` | Hook script for custom tethered shooting processing |

## 🖥️ GUI Alternatives

If you prefer a graphical interface, see [`canon_gui_tools.md`](canon_gui_tools.md) for recommended GUI applications:
- **Entangle** - Full-featured tethered shooting GUI
- **Darktable** - Professional photography workflow
- **digiKam** - Photo management and import

## 🔧 Troubleshooting

See [`CAMERA_TROUBLESHOOTING.md`](CAMERA_TROUBLESHOOTING.md) for detailed troubleshooting guide.

**Common Issues:**
- **"No camera found"** - Run `./release_camera.sh` and close file manager
- **"Device busy"** - Stop webcam stream: `./stop_canon_webcam.sh`
- **Download fails** - Make sure camera is in P/M/Av/Tv mode (not Auto)

## 💡 Why Open Source?

### Advantages over Canon's EOS Utility:

1. ✅ **Linux Support** - EOS Utility doesn't support Linux
2. ✅ **Webcam Mode** - Not available in EOS Utility
3. ✅ **Scriptable** - Automate your workflow
4. ✅ **No Restrictions** - Use with any compatible camera
5. ✅ **Privacy** - No telemetry or data collection
6. ✅ **Free Forever** - No license fees or subscriptions
7. ✅ **Customizable** - Modify to suit your needs

## 🎥 Use Cases

- **Video Conferencing** - High-quality webcam for Zoom, Teams, Discord
- **Streaming** - Use with OBS Studio for professional streams
- **Photography** - Remote control and tethered shooting
- **Time-lapse** - Create professional time-lapse videos
- **Automation** - Script your photography workflow

## 📝 Camera Settings

For best results, set your camera to:
- **P (Program)** - Full control
- **M (Manual)** - Full control  
- **Av (Aperture Priority)** - Full control
- **Tv (Shutter Priority)** - Full control
- **Movie Mode** - For video/webcam

**Avoid:** Auto mode or scene modes (may limit functionality)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is open source and available under the MIT License (or your preferred license).

## 🙏 Acknowledgments

- Built with [gphoto2](http://www.gphoto.org/)
- Uses [v4l2loopback](https://github.com/umlaeute/v4l2loopback) for webcam functionality
- Inspired by the need for open-source camera control on Linux

## 📚 Additional Resources

- [gphoto2 Documentation](http://www.gphoto.org/doc/remote/)
- [Canon Camera Compatibility](http://www.gphoto.org/proj/libgphoto2/support.php)
- [Linux Photography Workflow Guide](https://www.darktable.org/)

---

**Made with ❤️ for the open-source community**

*No proprietary software required. No vendor lock-in. Just freedom and control.*

