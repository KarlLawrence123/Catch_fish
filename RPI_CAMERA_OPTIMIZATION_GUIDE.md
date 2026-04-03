# 🎥 Raspberry Pi Camera Optimization Guide

This guide will help you optimize your Raspberry Pi camera server for better quality and lower latency.

---

## 📊 Current Performance Analysis

### App-Side Optimizations (✅ DONE)
- ✅ Frame skipping (shows 15fps instead of 30fps for lower latency)
- ✅ Reduced buffer size (512KB instead of 1MB)
- ✅ Optimized frame parsing
- ✅ Better memory management

### RPi Server-Side Optimizations (👇 DO THIS)

---

## 🔧 Raspberry Pi Server Optimization

### 1. **Adjust Camera Resolution** (Quality vs Speed)

**For Better Quality (slower):**
```python
# In your Flask server code
camera.resolution = (1920, 1080)  # Full HD - high quality, more latency
```

**For Lower Latency (recommended):**
```python
camera.resolution = (1280, 720)   # HD - good balance
# OR
camera.resolution = (640, 480)    # VGA - fastest, lowest latency
```

**Recommendation:** Start with `(1280, 720)` for a good balance.

---

### 2. **Adjust Frame Rate**

**Lower FPS = Less bandwidth, less processing:**
```python
camera.framerate = 15  # Recommended for smooth streaming with low latency
# OR
camera.framerate = 30  # Higher quality but more bandwidth
```

**Recommendation:** Use `15 FPS` since the app now skips frames anyway.

---

### 3. **Optimize JPEG Quality**

**In your Flask video_feed route:**
```python
def generate_frames():
    while True:
        frame = camera.capture()
        # Adjust quality: 50-70 = faster, 80-95 = better quality
        ret, buffer = cv2.imencode('.jpg', frame, [cv2.IMWRITE_JPEG_QUALITY, 70])
        frame = buffer.tobytes()
        yield (b'--frame\r\n'
               b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')
```

**Quality Settings:**
- `50-60` = Fastest, lowest latency, acceptable quality
- `70-80` = Good balance (recommended)
- `85-95` = Best quality, higher latency

---

### 4. **Optimize Camera Settings**

```python
from picamera import PiCamera

camera = PiCamera()
camera.resolution = (1280, 720)
camera.framerate = 15

# Reduce latency
camera.exposure_mode = 'auto'
camera.awb_mode = 'auto'
camera.image_denoise = False  # Disable denoising for faster processing

# For underwater/low light (NoIR camera)
camera.iso = 800  # Increase ISO for better low-light performance
camera.shutter_speed = 0  # Auto shutter speed
```

---

### 5. **Network Optimization**

**Use WiFi 5GHz instead of 2.4GHz:**
- Less interference
- Higher bandwidth
- Lower latency

**Check your network:**
```bash
# On Raspberry Pi
ping 192.168.100.113  # Your phone/computer IP
# Should be < 10ms for good performance
```

---

### 6. **Example Optimized Flask Server**

```python
from flask import Flask, Response
from picamera2 import Picamera2
import cv2
import io

app = Flask(__name__)

# Initialize camera with optimized settings
camera = Picamera2()
config = camera.create_video_configuration(
    main={"size": (1280, 720), "format": "RGB888"},
    controls={"FrameRate": 15}
)
camera.configure(config)
camera.start()

def generate_frames():
    while True:
        # Capture frame
        frame = camera.capture_array()
        
        # Convert to JPEG with quality 70 (good balance)
        ret, buffer = cv2.imencode('.jpg', frame, 
                                   [cv2.IMWRITE_JPEG_QUALITY, 70])
        
        if not ret:
            continue
            
        # Yield frame in MJPEG format
        yield (b'--frame\r\n'
               b'Content-Type: image/jpeg\r\n\r\n' + 
               buffer.tobytes() + b'\r\n')

@app.route('/video_feed1')
def video_feed1():
    return Response(generate_frames(),
                    mimetype='multipart/x-mixed-replace; boundary=frame')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, threaded=True)
```

---

## 🎯 Recommended Settings for Your Setup

### For Best Balance (Quality + Speed):
```python
Resolution: 1280x720
Frame Rate: 15 FPS
JPEG Quality: 70
ISO: 400-800 (for underwater/low light)
```

### For Lowest Latency:
```python
Resolution: 640x480
Frame Rate: 15 FPS
JPEG Quality: 60
Disable image processing (denoise, etc.)
```

### For Best Quality:
```python
Resolution: 1920x1080
Frame Rate: 15 FPS
JPEG Quality: 85
```

---

## 📈 Performance Expectations

| Setting | Latency | Quality | Bandwidth |
|---------|---------|---------|-----------|
| 640x480 @ 15fps, Q60 | ~100-200ms | Good | Low |
| 1280x720 @ 15fps, Q70 | ~200-400ms | Very Good | Medium |
| 1920x1080 @ 15fps, Q85 | ~400-600ms | Excellent | High |

---

## 🔍 Troubleshooting

### High Latency (>1 second delay)
1. Reduce resolution to 640x480
2. Lower JPEG quality to 60
3. Check WiFi signal strength
4. Use 5GHz WiFi instead of 2.4GHz

### Poor Image Quality
1. Increase JPEG quality to 80-85
2. Increase resolution to 1280x720 or 1920x1080
3. Adjust ISO for lighting conditions
4. Enable auto white balance

### Choppy/Stuttering Video
1. Ensure stable WiFi connection
2. Reduce frame rate to 10-15 FPS
3. Lower resolution
4. Check RPi CPU usage (should be < 80%)

---

## 💡 Pro Tips

1. **Test different settings** - Every setup is different
2. **Monitor RPi temperature** - Overheating reduces performance
3. **Use ethernet cable** if possible for most stable connection
4. **Restart RPi** if stream becomes unstable
5. **Update RPi firmware** regularly for best performance

---

## 🚀 Quick Start Command

SSH into your Raspberry Pi and update your camera settings:

```bash
# Edit your Flask server file
nano /path/to/your/camera_server.py

# Apply the optimized settings above
# Then restart the server
sudo systemctl restart camera-server  # Or however you run it
```

---

**Need help?** The app-side optimizations are already done. Just adjust your RPi server settings above! 🎥✨
