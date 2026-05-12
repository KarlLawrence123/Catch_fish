#!/usr/bin/env python3
"""
Catfish Disease Detector - RPi Camera Server
This server handles:
- Dual camera streaming (Overhead + Underwater)
- Manual image capture
- Image storage and serving
"""

import io
import time
from flask import Flask, Response, jsonify, send_from_directory
from picamera2 import Picamera2
from PIL import Image
import os
from datetime import datetime

app = Flask(__name__)

# --- Camera Settings ---
RESOLUTION = (1280, 720)
FRAME_RATE = 30
JPEG_QUALITY = 75

# Create directory for captured images
CAPTURE_DIR = "/home/karllaw/camera_captures"
os.makedirs(CAPTURE_DIR, exist_ok=True)

# --- Initialize Camera 1 (CSI Port 0 - Overhead) ---
picam1 = Picamera2(0)
config1 = picam1.create_video_configuration(
    main={"size": RESOLUTION, "format": "RGB888"},
    controls={"FrameRate": FRAME_RATE}
)
picam1.configure(config1)
picam1.set_controls({
    "AwbEnable": True,
    "AeEnable": True,
    "Saturation": 1.0,
    "Contrast": 1.0,
    "Brightness": 0.0,
    "Sharpness": 1.5,
})
picam1.start()
time.sleep(2)

# --- Initialize Camera 2 (CSI Port 1 - Underwater/NoIR) ---
picam2 = Picamera2(1)
config2 = picam2.create_video_configuration(
    main={"size": RESOLUTION, "format": "RGB888"},
    controls={"FrameRate": FRAME_RATE}
)
picam2.configure(config2)
picam2.set_controls({
    "AwbEnable": True,
    "AeEnable": True,
    "AnalogueGain": 2.0,
    "Saturation": 1.2,
    "Contrast": 1.1,
    "Brightness": 0.1,
    "Sharpness": 1.5,
})
picam2.start()
time.sleep(2)

def generate_frames(camera_obj):
    """Generate MJPEG frames for streaming"""
    while True:
        try:
            frame = camera_obj.capture_array()
            img = Image.fromarray(frame)
            buf = io.BytesIO()
            img.save(buf, format='JPEG', quality=JPEG_QUALITY, optimize=True)
            jpeg_data = buf.getvalue()
            
            yield (b'--frame\r\n'
                   b'Content-Type: image/jpeg\r\n\r\n' + jpeg_data + b'\r\n')
            
            time.sleep(0.033)  # ~30 FPS
            
        except Exception as e:
            print(f"Camera error: {e}")
            time.sleep(0.1)
            continue

@app.route('/')
def index():
    """Health check endpoint"""
    return jsonify({
        'status': 'running',
        'cameras': 2,
        'resolution': RESOLUTION,
        'fps': FRAME_RATE,
        'quality': JPEG_QUALITY
    })

@app.route('/video_feed1')
def video_feed1():
    """Camera 1 - Overhead View"""
    return Response(generate_frames(picam1),
                    mimetype='multipart/x-mixed-replace; boundary=frame')

@app.route('/video_feed2')
def video_feed2():
    """Camera 2 - Underwater View"""
    return Response(generate_frames(picam2),
                    mimetype='multipart/x-mixed-replace; boundary=frame')

@app.route('/capture')
def capture_image():
    """Capture current frame from Camera 1"""
    try:
        frame = picam1.capture_array()
        img = Image.fromarray(frame)
        
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"capture_{timestamp}.jpg"
        filepath = os.path.join(CAPTURE_DIR, filename)
        
        img.save(filepath, format='JPEG', quality=95)
        
        print(f"✅ Image captured: {filepath}")
        
        return jsonify({
            'success': True,
            'filename': filename,
            'filepath': filepath,
            'timestamp': timestamp,
            'resolution': RESOLUTION
        })
        
    except Exception as e:
        print(f"❌ Capture error: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/capture2')
def capture_image2():
    """Capture current frame from Camera 2"""
    try:
        frame = picam2.capture_array()
        img = Image.fromarray(frame)
        
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"capture_cam2_{timestamp}.jpg"
        filepath = os.path.join(CAPTURE_DIR, filename)
        
        img.save(filepath, format='JPEG', quality=95)
        
        print(f"✅ Image captured from Camera 2: {filepath}")
        
        return jsonify({
            'success': True,
            'filename': filename,
            'filepath': filepath,
            'timestamp': timestamp,
            'camera': 2
        })
        
    except Exception as e:
        print(f"❌ Capture error: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/images/<filename>')
def serve_image(filename):
    """Serve captured images for download"""
    try:
        return send_from_directory(CAPTURE_DIR, filename)
    except Exception as e:
        return jsonify({'error': str(e)}), 404

if __name__ == '__main__':
    try:
        print("=" * 60)
        print("🎥 Catfish Disease Detector - Camera Server")
        print("=" * 60)
        print(f"📊 Resolution: {RESOLUTION}")
        print(f"🎬 Frame Rate: {FRAME_RATE} FPS")
        print(f"🖼️  JPEG Quality: {JPEG_QUALITY}")
        print(f"✨ Auto White Balance: Enabled")
        print(f"📁 Captures saved to: {CAPTURE_DIR}")
        print(f"🌐 Server: http://10.42.1.0:5000")
        print(f"📹 Camera 1: http://10.42.1.0:5000/video_feed1")
        print(f"📹 Camera 2: http://10.42.1.0:5000/video_feed2")
        print(f"📸 Capture 1: http://10.42.1.0:5000/capture")
        print(f"📸 Capture 2: http://10.42.1.0:5000/capture2")
        print(f"🖼️  Images: http://10.42.1.0:5000/images/<filename>")
        print("=" * 60)
        
        app.run(host='0.0.0.0', port=5000, debug=False, threaded=True)
    except KeyboardInterrupt:
        print("\n🛑 Shutting down...")
        picam1.stop()
        picam2.stop()
        print("✅ Cameras stopped")
