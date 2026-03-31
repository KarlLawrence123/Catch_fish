# Raspberry Pi Camera Integration for Catfish Disease Detector

## 🎯 Overview
Your Flutter app now supports **both mobile and Raspberry Pi cameras**! This guide shows you how to set up RPi camera integration for remote monitoring.

## 🔧 What We've Added

### ✅ New Features
- **Network camera streaming** from RPi to your Flutter app
- **Dual camera support** (Mobile + RPi) with easy switching
- **RPi camera settings** interface
- **Real-time video streaming** using MJPEG
- **Camera status monitoring** and connection testing

### 📦 New Dependencies Added
```yaml
http: ^1.1.0           # For RPi camera communication
video_player: ^2.8.1   # For video streaming
chewie: ^1.7.4         # Enhanced video player
```

## 🚀 Setup Instructions

### Step 1: Setup Raspberry Pi Camera Server

#### 1.1 Enable Camera on RPi
```bash
# On Raspberry Pi
sudo raspi-config
# Navigate to: Interface Options > Camera > Enable
```

#### 1.2 Install Required Packages
```bash
sudo apt update
sudo apt install python3-pip python3-opencv
pip3 install flask opencv-python picamera2
```

#### 1.3 Create Camera Server Script
Create `/home/pi/camera_server.py`:

```python
from flask import Flask, Response, jsonify
from picamera2 import Picamera2
import cv2
import threading
import time

app = Flask(__name__)
picam2 = Picamera2()

# Configure camera
picam2.configure(picam2.create_preview_configuration(main={"size": (640, 480)}))
picam2.start()

def generate_frames():
    """Generate MJPEG stream from RPi camera"""
    while True:
        frame = picam2.capture_array()
        ret, buffer = cv2.imencode('.jpg', frame)
        frame_bytes = buffer.tobytes()
        
        yield (b'--frame\r\n'
               b'Content-Type: image/jpeg\r\n\r\n' + frame_bytes + b'\r\n')

@app.route('/video_feed')
def video_feed():
    """Video streaming route"""
    return Response(generate_frames(),
                    mimetype='multipart/x-mixed-replace; boundary=frame')

@app.route('/capture')
def capture_image():
    """Capture still image"""
    frame = picam2.capture_array()
    ret, buffer = cv2.imencode('.jpg', frame)
    if ret:
        return Response(buffer.tobytes(), mimetype='image/jpeg')
    return "Capture failed", 500

@app.route('/status')
def camera_status():
    """Get camera status"""
    return jsonify({
        'connected': True,
        'camera_active': True,
        'resolution': '640x480',
        'fps': 30
    })

@app.route('/')
def index():
    return "RPi Camera Server Running!"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, threaded=True)
```

#### 1.4 Start the Camera Server
```bash
python3 camera_server.py
```

### Step 2: Configure Flutter App

#### 2.1 Find Your RPi IP Address
```bash
# On RPi
hostname -I
# Or check your router's connected devices
```

#### 2.2 Update App Settings
1. Open your Flutter app
2. Go to **Monitoring Screen**
3. Click the **router icon** to switch to RPi camera
4. Click **settings icon** to configure RPi server URL
5. Enter your RPi IP: `http://YOUR_RPI_IP:5000`
6. Click **Test** to verify connection
7. Click **Save** when successful

### Step 3: Use RPi Camera

#### 3.1 Switch Camera Sources
- **Mobile Camera**: Click phone icon 📱
- **RPi Camera**: Click router icon 📡

#### 3.2 Monitor Features
- **Live streaming** from RPi camera
- **Image capture** for disease detection
- **Real-time status** monitoring
- **Settings configuration**

## 🎮 App Features

### Camera Switching
```
[Mobile Camera] <--> [RPi Camera]
     📱                    📡
```

### Status Indicators
- 🟢 **Green**: RPi connected and active
- 🔴 **Red**: RPi offline or connection issue
- 🟡 **Yellow**: Testing connection

### Settings Panel
- **Server URL**: Configure RPi IP address
- **Connection Test**: Verify RPi availability
- **Save Settings**: Store configuration

## 🔍 Troubleshooting

### Common Issues

#### 1. "RPi Offline" Status
**Solutions:**
- Check RPi is powered on
- Verify RPi and phone are on same WiFi network
- Confirm camera server is running (`python3 camera_server.py`)
- Check firewall settings on RPi

#### 2. Video Stream Not Working
**Solutions:**
- Restart camera server on RPi
- Check RPi camera is properly connected
- Verify URL format: `http://IP:5000`
- Test with browser: `http://IP:5000/video_feed`

#### 3. Connection Timeout
**Solutions:**
- Check network connectivity
- Verify RPi IP address
- Ensure port 5000 is open
- Restart both RPi and Flutter app

### Network Setup Tips

#### WiFi Network
- Ensure both devices on same network
- Check signal strength
- Avoid VPN or proxy connections

#### Static IP (Recommended)
```bash
# On RPi, set static IP
sudo nano /etc/dhcpcd.conf
# Add:
interface wlan0
static ip_address=192.168.1.100/24
static routers=192.168.1.1
static domain_name_servers=192.168.1.1
```

## 🌊 Integration with Your App

### Enhanced Monitoring Screen
Your existing monitoring screen now includes:
- **Camera source toggle** (Mobile/ RPi)
- **RPi status indicator**
- **Settings configuration**
- **Live video streaming**

### Disease Detection
- Works with both camera sources
- Captures images from RPi for AI analysis
- Stores detection results in database
- Real-time alerts and notifications

## 🎯 Use Cases

### 1. Remote Pond Monitoring
- Place RPi camera above fish pond
- Monitor from anywhere using your phone
- Get real-time disease detection alerts

### 2. Multi-Angle Viewing
- Use mobile camera for close-up shots
- Use RPi camera for overhead monitoring
- Switch between views seamlessly

### 3. Automated Monitoring
- Set up RPi for 24/7 monitoring
- Receive alerts when diseases detected
- Review captured images and analysis

## 🚀 Next Steps

1. **Setup RPi camera server** following the guide
2. **Configure Flutter app** with RPi IP
3. **Test connection** and video streaming
4. **Start monitoring** your catfish remotely!

## 📞 Support

If you encounter issues:
1. Check RPi camera server is running
2. Verify network connectivity
3. Test URL in browser first
4. Restart both devices if needed

Your **catfish disease detector** now supports professional-grade remote monitoring with Raspberry Pi integration! 🐠🌊
