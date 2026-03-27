# Raspberry Pi Camera Integration Guide

## Overview
This guide explains how to connect a Raspberry Pi camera to the Catfish Disease Detector app for live monitoring and offline image capture.

## Hardware Requirements

### Option 1: Raspberry Pi as Camera Server
- Raspberry Pi 3/4/5 (recommended: Pi 4 or newer)
- Raspberry Pi Camera Module V2 or V3
- MicroSD card (16GB minimum)
- Power supply for Raspberry Pi
- Network connection (WiFi or Ethernet)

### Option 2: Direct USB Camera
- USB webcam compatible with Android
- USB OTG adapter (for connecting to Android phone/tablet)

## Setup Methods

### Method 1: Raspberry Pi Camera Server (Recommended for Offline Use)

#### Step 1: Setup Raspberry Pi Camera
```bash
# On Raspberry Pi, enable camera interface
sudo raspi-config
# Navigate to: Interface Options > Camera > Enable

# Install required packages
sudo apt-get update
sudo apt-get install python3-pip python3-opencv
pip3 install flask opencv-python picamera2
```

#### Step 2: Create Camera Server Script
Create a file `/home/pi/camera_server.py`:

```python
from flask import Flask, Response
from picamera2 import Picamera2
import cv2

app = Flask(__name__)
picam2 = Picamera2()
picam2.configure(picam2.create_preview_configuration(main={"size": (640, 480)}))
picam2.start()

def generate_frames():
    while True:
        frame = picam2.capture_array()
        # Convert RGB to BGR for OpenCV
        frame = cv2.cvtColor(frame, cv2.COLOR_RGB2BGR)
        
        # Encode frame as JPEG
        ret, buffer = cv2.imencode('.jpg', frame)
        frame = buffer.tobytes()
        
        yield (b'--frame\r\n'
               b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')

@app.route('/video_feed')
def video_feed():
    return Response(generate_frames(),
                    mimetype='multipart/x-mixed-replace; boundary=frame')

@app.route('/capture')
def capture():
    frame = picam2.capture_array()
    frame = cv2.cvtColor(frame, cv2.COLOR_RGB2BGR)
    ret, buffer = cv2.imencode('.jpg', frame)
    return Response(buffer.tobytes(), mimetype='image/jpeg')

if __name__ == '__main__':
    # Run on all network interfaces, port 5000
    app.run(host='0.0.0.0', port=5000, threaded=True)
```

#### Step 3: Auto-start Camera Server
```bash
# Create systemd service
sudo nano /etc/systemd/system/camera-server.service

# Add the following content:
[Unit]
Description=Camera Server for Catfish Detector
After=network.target

[Service]
ExecStart=/usr/bin/python3 /home/pi/camera_server.py
WorkingDirectory=/home/pi
StandardOutput=inherit
StandardError=inherit
Restart=always
User=pi

[Install]
WantedBy=multi-user.target

# Enable and start the service
sudo systemctl enable camera-server.service
sudo systemctl start camera-server.service
```

#### Step 4: Find Raspberry Pi IP Address
```bash
# On Raspberry Pi
hostname -I
# Example output: 192.168.1.100
```

#### Step 5: Configure App to Use Camera
In the app's dual stream monitoring screen, use:
- **Camera 1 URL**: `http://192.168.1.100:5000/video_feed`
- **Camera 2 URL**: `http://192.168.1.100:5000/video_feed` (or another Pi)
- **Capture URL**: `http://192.168.1.100:5000/capture`

### Method 2: USB Camera (Direct Connection)

#### Step 1: Connect USB Camera
1. Connect USB camera to Android device using USB OTG adapter
2. Grant camera permissions when prompted

#### Step 2: App Configuration
The app will automatically detect USB cameras connected to the device.

## App Configuration

### Update Dual Stream Monitoring Screen

The app stores camera URLs in SharedPreferences for offline persistence:

```dart
// Save camera URLs
final prefs = await SharedPreferences.getInstance();
await prefs.setString('camera1_url', 'http://192.168.1.100:5000/video_feed');
await prefs.setString('camera2_url', 'http://192.168.1.101:5000/video_feed');
```

### Offline Image Storage

Images captured from the camera are stored in two ways:

1. **SQLite Database (BLOB)**: For complete offline access
   - Images stored as binary data
   - No external files needed
   - Survives app reinstall if database is backed up

2. **Local File System**: For faster access
   - Images saved to app's documents directory
   - Path stored in database for reference

## Network Configuration for Offline Use

### Local WiFi Network (No Internet Required)

1. **Setup Raspberry Pi as WiFi Access Point**:
```bash
# Install required packages
sudo apt-get install hostapd dnsmasq

# Configure static IP
sudo nano /etc/dhcpcd.conf
# Add:
interface wlan0
static ip_address=192.168.4.1/24
nogateway

# Configure hostapd
sudo nano /etc/hostapd/hostapd.conf
# Add:
interface=wlan0
driver=nl80211
ssid=CatfishMonitor
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=catfish123
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP

# Enable services
sudo systemctl unmask hostapd
sudo systemctl enable hostapd
sudo systemctl start hostapd
```

2. **Connect Android Device**:
   - WiFi Network: `CatfishMonitor`
   - Password: `catfish123`
   - Camera URL: `http://192.168.4.1:5000/video_feed`

## Testing the Setup

### Test Camera Stream
1. Open browser on Android device
2. Navigate to: `http://192.168.1.100:5000/video_feed`
3. You should see live camera feed

### Test Image Capture
1. Navigate to: `http://192.168.1.100:5000/capture`
2. Should download a single JPEG image

### Test in App
1. Open Catfish Disease Detector app
2. Navigate to "Live Monitoring"
3. Enter camera URL
4. Tap "Capture" to save image to database

## Troubleshooting

### Camera Not Detected
```bash
# Check if camera is enabled
vcgencmd get_camera
# Should show: supported=1 detected=1

# Test camera
libcamera-hello
```

### Server Not Starting
```bash
# Check service status
sudo systemctl status camera-server.service

# View logs
sudo journalctl -u camera-server.service -f
```

### Cannot Connect from App
```bash
# Check if server is running
sudo netstat -tulpn | grep 5000

# Test from Pi itself
curl http://localhost:5000/video_feed

# Check firewall
sudo ufw status
sudo ufw allow 5000
```

### Poor Video Quality
Edit `/home/pi/camera_server.py`:
```python
# Increase resolution
picam2.configure(picam2.create_preview_configuration(main={"size": (1280, 720)}))

# Adjust JPEG quality
ret, buffer = cv2.imencode('.jpg', frame, [cv2.IMWRITE_JPEG_QUALITY, 90])
```

## Power Considerations

### Battery-Powered Setup
- Use Raspberry Pi Zero 2 W (lower power consumption)
- Add battery pack (10,000mAh recommended)
- Expected runtime: 8-12 hours

### Solar-Powered Setup
- 20W solar panel
- 12V battery with charge controller
- 5V step-down converter for Pi
- Can run 24/7 in sunny locations

## Security Notes

- Change default password: `catfish123`
- Use WPA3 if available
- Disable SSH if not needed
- Keep Raspberry Pi OS updated

## Advanced: Multiple Cameras

To monitor multiple ponds:

1. Setup multiple Raspberry Pis, each with unique IP
2. Configure each in the app:
   - Pond 1: `http://192.168.4.10:5000/video_feed`
   - Pond 2: `http://192.168.4.11:5000/video_feed`
   - Pond 3: `http://192.168.4.12:5000/video_feed`

## Cost Estimate

- Raspberry Pi 4 (2GB): $35
- Camera Module V2: $25
- MicroSD Card (32GB): $8
- Power Supply: $8
- Case: $5
- **Total per camera**: ~$81

## Support

For issues or questions, refer to:
- Raspberry Pi Camera Documentation: https://www.raspberrypi.com/documentation/accessories/camera.html
- Picamera2 Library: https://github.com/raspberrypi/picamera2
