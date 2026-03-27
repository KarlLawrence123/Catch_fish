# Camera Quick Start Guide

## 🎯 Quick Setup (5 Minutes)

### Option 1: Raspberry Pi Camera (Recommended for Offline)

#### What You Need:
- Raspberry Pi (any model with camera port)
- Raspberry Pi Camera Module
- Power supply
- WiFi connection (or create local network)

#### Setup Steps:

1. **Connect Camera to Raspberry Pi**
   - Power off Raspberry Pi
   - Connect camera ribbon cable to camera port
   - Power on Raspberry Pi

2. **Enable Camera**
   ```bash
   sudo raspi-config
   # Select: Interface Options > Camera > Enable
   sudo reboot
   ```

3. **Install Camera Server**
   ```bash
   # One-line install script
   curl -sSL https://raw.githubusercontent.com/yourusername/catfish-camera/main/install.sh | bash
   ```

   Or manually:
   ```bash
   sudo apt-get update
   sudo apt-get install -y python3-pip python3-opencv
   pip3 install flask opencv-python picamera2
   
   # Download server script
   wget https://raw.githubusercontent.com/yourusername/catfish-camera/main/camera_server.py
   
   # Run server
   python3 camera_server.py
   ```

4. **Find Raspberry Pi IP Address**
   ```bash
   hostname -I
   # Example: 192.168.1.100
   ```

5. **Test Camera**
   - Open browser on phone: `http://192.168.1.100:5000/video_feed`
   - You should see live video!

6. **Configure App**
   - Open Catfish Disease Detector app
   - Go to "Live Monitoring"
   - Enter camera URL: `http://192.168.1.100:5000/video_feed`
   - Tap "Connect"

### Option 2: USB Camera (Simplest)

1. Connect USB camera to Android device using USB OTG adapter
2. Grant camera permissions
3. Open app - camera will be detected automatically!

## 📱 Using the App

### Capture Images
1. Open "Live Monitoring" screen
2. View live camera feed
3. Tap "Capture" button
4. Image saved to local database (works offline!)

### View Captured Images
1. Go to "History" screen
2. All captured images stored locally
3. No internet needed to view

### Offline Storage
- Images stored in SQLite database as BLOB
- Also saved as files in app directory
- Survives app restart
- No cloud needed

## 🔧 Troubleshooting

### Can't See Camera Feed
```bash
# On Raspberry Pi, check if camera is detected
vcgencmd get_camera
# Should show: supported=1 detected=1

# Restart camera server
sudo systemctl restart camera-server
```

### App Can't Connect
- Check WiFi connection
- Verify IP address hasn't changed
- Ping Raspberry Pi: `ping 192.168.1.100`
- Check firewall: `sudo ufw allow 5000`

### Poor Image Quality
Edit camera server settings:
```python
# Higher resolution
picam2.configure(picam2.create_preview_configuration(main={"size": (1280, 720)}))

# Better JPEG quality
ret, buffer = cv2.imencode('.jpg', frame, [cv2.IMWRITE_JPEG_QUALITY, 95])
```

## 💡 Tips

### For Best Results:
- Position camera 30-50cm above water
- Ensure good lighting (natural or LED)
- Clean camera lens regularly
- Use waterproof case for outdoor use

### Battery Life:
- Raspberry Pi Zero 2 W: 8-12 hours on 10,000mAh battery
- Add solar panel for 24/7 operation
- Use power bank with pass-through charging

### Multiple Ponds:
- Setup one Raspberry Pi per pond
- Each gets unique IP address
- Monitor all from single app
- Example:
  - Pond 1: `http://192.168.1.100:5000/video_feed`
  - Pond 2: `http://192.168.1.101:5000/video_feed`
  - Pond 3: `http://192.168.1.102:5000/video_feed`

## 🌐 Offline Network Setup

### Create Local WiFi (No Internet Needed)

1. **Setup Raspberry Pi as Access Point**
   ```bash
   # Quick setup script
   sudo apt-get install -y hostapd dnsmasq
   
   # Configure network
   sudo nano /etc/dhcpcd.conf
   # Add: interface wlan0
   #      static ip_address=192.168.4.1/24
   
   # Configure WiFi
   sudo nano /etc/hostapd/hostapd.conf
   # Add: interface=wlan0
   #      ssid=CatfishMonitor
   #      wpa_passphrase=catfish123
   
   # Start services
   sudo systemctl enable hostapd
   sudo systemctl start hostapd
   ```

2. **Connect Phone to Raspberry Pi WiFi**
   - Network: `CatfishMonitor`
   - Password: `catfish123`
   - Camera URL: `http://192.168.4.1:5000/video_feed`

3. **Works Completely Offline!**
   - No internet required
   - Perfect for remote fish ponds
   - All data stored locally

## 📊 Storage Capacity

### Database Size Estimates:
- 1 image (compressed): ~100-200 KB
- 100 images: ~10-20 MB
- 1,000 images: ~100-200 MB
- 10,000 images: ~1-2 GB

### Recommendations:
- 32GB storage: ~150,000 images
- Clean old images periodically
- Export important detections

## 🔐 Security

### Change Default Password:
```bash
# On Raspberry Pi
sudo raspi-config
# Select: System Options > Password
```

### Secure WiFi:
- Change `catfish123` to strong password
- Use WPA3 if available
- Disable SSH if not needed

## 💰 Cost Breakdown

### Budget Setup (~$50):
- Raspberry Pi Zero 2 W: $15
- Camera Module: $25
- MicroSD Card: $8
- Power supply: $8

### Premium Setup (~$80):
- Raspberry Pi 4 (2GB): $35
- Camera Module V3: $25
- MicroSD Card (32GB): $8
- Power supply: $8
- Case: $5

### Solar Setup (~$150):
- Raspberry Pi 4: $35
- Camera Module: $25
- 20W Solar Panel: $40
- Battery + Controller: $35
- Waterproof case: $15

## 📞 Support

### Common Issues:
1. **Camera not working**: Check ribbon cable connection
2. **No video feed**: Verify IP address and port
3. **App crashes**: Grant camera permissions
4. **Slow performance**: Reduce resolution or quality

### Need Help?
- Check full guide: `RASPBERRY_PI_CAMERA_SETUP.md`
- Test camera: `libcamera-hello`
- View logs: `sudo journalctl -u camera-server -f`

## ✅ Checklist

Before first use:
- [ ] Camera connected and enabled
- [ ] Server script running
- [ ] IP address noted
- [ ] App configured with camera URL
- [ ] Test capture successful
- [ ] Images saving to database

You're ready to monitor your catfish! 🐟
