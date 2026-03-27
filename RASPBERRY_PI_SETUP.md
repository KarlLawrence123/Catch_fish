# Raspberry Pi 5 Integration Guide

## Overview
This guide explains how to set up your Raspberry Pi 5 to capture images from dual cameras and run TensorFlow Lite inference for catfish disease detection. The images are streamed to the Flutter app via a REST API.

## Hardware Requirements

### Raspberry Pi 5 Setup
- **Raspberry Pi 5** (4GB or 8GB RAM recommended)
- **Raspberry Pi OS** (Bookworm or later)
- **Power Supply**: 27W USB-C (official recommended)
- **MicroSD Card**: 64GB+ (fast UHS-II recommended)

### Camera Setup
1. **Overhead Camera**: Raspberry Pi Camera Module 3 (standard)
   - For detecting Columnaris and general swimming behavior
   - Mount above the pond at 45-60° angle

2. **Underwater Camera**: Raspberry Pi Camera Module 3 NoIR (infrared)
   - For detecting Fin Rot and White Spot Disease
   - Mount underwater in waterproof housing
   - Use IR LED illuminators for night mode

3. **IR LED Illuminators**: ATmega328P-controlled IR LEDs
   - Connected to Raspberry Pi GPIO pins
   - Controlled via REST API from the Flutter app

## Software Setup

### 1. Install Raspberry Pi OS
```bash
# Use Raspberry Pi Imager to flash OS to microSD card
# Enable SSH and set up WiFi during setup
```

### 2. Update System
```bash
sudo apt update
sudo apt upgrade -y
sudo apt install -y python3-pip python3-venv git
```

### 3. Install TensorFlow Lite
```bash
# Create virtual environment
python3 -m venv ~/tflite_env
source ~/tflite_env/bin/activate

# Install TensorFlow Lite
pip install --index-url https://google-coral.github.io/py-repo/ tflite-runtime
pip install numpy pillow opencv-python flask
```

### 4. Enable Camera Interfaces
```bash
sudo raspi-config
# Navigate to: Interface Options > Camera > Enable
# Navigate to: Interface Options > I2C > Enable (for sensors)
# Reboot
```

### 5. Create Flask API Server

Create `/home/pi/catfish_detector/app.py`:

```python
from flask import Flask, jsonify, request
from picamera2 import Picamera2
import tflite_runtime.interpreter as tflite
import numpy as np
import base64
import io
from PIL import Image
import RPi.GPIO as GPIO
import json
from datetime import datetime

app = Flask(__name__)

# Initialize cameras
picam2_overhead = Picamera2(0)  # Overhead camera
picam2_underwater = Picamera2(1)  # Underwater NoIR camera

# Camera configurations
config_overhead = picam2_overhead.create_preview_configuration(
    main={"format": 'XRGB8888', "size": (640, 480)}
)
config_underwater = picam2_underwater.create_preview_configuration(
    main={"format": 'XRGB8888', "size": (640, 480)}
)

picam2_overhead.configure(config_overhead)
picam2_underwater.configure(config_underwater)
picam2_overhead.start()
picam2_underwater.start()

# Load TensorFlow Lite model
interpreter = tflite.Interpreter(model_path="/home/pi/catfish_detector/model.tflite")
interpreter.allocate_tensors()

# GPIO setup for IR LED
IR_LED_PIN = 17
GPIO.setmode(GPIO.BCM)
GPIO.setup(IR_LED_PIN, GPIO.OUT)
GPIO.output(IR_LED_PIN, GPIO.LOW)

# Store latest images
latest_overhead = None
latest_underwater = None

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({"status": "healthy"}), 200

@app.route('/api/latest-image', methods=['GET'])
def get_latest_image():
    """Get latest captured image"""
    global latest_overhead, latest_underwater
    
    try:
        # Capture from overhead camera
        frame = picam2_overhead.capture_array()
        
        # Convert to PIL Image
        img = Image.fromarray(frame)
        
        # Encode to base64
        buffered = io.BytesIO()
        img.save(buffered, format="JPEG")
        img_base64 = base64.b64encode(buffered.getvalue()).decode()
        
        latest_overhead = img_base64
        
        return jsonify({
            "image": img_base64,
            "timestamp": datetime.now().isoformat(),
            "camera": "overhead"
        }), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/capture', methods=['POST'])
def capture_image():
    """Capture a single image"""
    try:
        frame = picam2_overhead.capture_array()
        img = Image.fromarray(frame)
        
        buffered = io.BytesIO()
        img.save(buffered, format="JPEG")
        img_base64 = base64.b64encode(buffered.getvalue()).decode()
        
        return jsonify({
            "image": img_base64,
            "timestamp": datetime.now().isoformat()
        }), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/detect', methods=['POST'])
def detect_disease():
    """Run TensorFlow Lite inference on image"""
    try:
        data = request.get_json()
        img_base64 = data.get('image')
        
        # Decode base64 image
        img_data = base64.b64decode(img_base64)
        img = Image.open(io.BytesIO(img_data))
        
        # Resize to model input size (adjust based on your model)
        img = img.resize((224, 224))
        img_array = np.array(img, dtype=np.float32) / 255.0
        
        # Run inference
        input_details = interpreter.get_input_details()
        output_details = interpreter.get_output_details()
        
        interpreter.set_tensor(input_details[0]['index'], np.expand_dims(img_array, axis=0))
        interpreter.invoke()
        
        output_data = interpreter.get_tensor(output_details[0]['index'])
        
        # Process results (adjust based on your model output)
        disease_classes = ['Healthy', 'Columnaris', 'Fin Rot', 'White Spot', 'Aeromonas']
        confidence = float(np.max(output_data[0]))
        disease_index = int(np.argmax(output_data[0]))
        disease_name = disease_classes[disease_index]
        
        # Determine severity
        if confidence < 0.5:
            severity = 'early'
        elif confidence < 0.8:
            severity = 'acute'
        else:
            severity = 'critical'
        
        return jsonify({
            "disease": disease_name,
            "confidence": confidence,
            "severity": severity,
            "timestamp": datetime.now().isoformat()
        }), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/ir-led', methods=['POST'])
def toggle_ir_led():
    """Toggle IR LED for night mode"""
    try:
        data = request.get_json()
        enabled = data.get('enabled', False)
        
        if enabled:
            GPIO.output(IR_LED_PIN, GPIO.HIGH)
        else:
            GPIO.output(IR_LED_PIN, GPIO.LOW)
        
        return jsonify({
            "status": "on" if enabled else "off",
            "timestamp": datetime.now().isoformat()
        }), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/sensors', methods=['GET'])
def get_sensor_data():
    """Get environmental sensor data (temperature, pH)"""
    try:
        # TODO: Integrate with your ATmega328P sensor data
        # This is a placeholder - connect to your actual sensors
        
        return jsonify({
            "temperature": 28.5,  # Celsius
            "pH": 7.2,
            "timestamp": datetime.now().isoformat()
        }), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/shutdown', methods=['POST'])
def shutdown():
    """Graceful shutdown"""
    try:
        picam2_overhead.stop()
        picam2_underwater.stop()
        GPIO.cleanup()
        return jsonify({"status": "shutdown"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
```

### 6. Create Systemd Service

Create `/etc/systemd/system/catfish-detector.service`:

```ini
[Unit]
Description=Catfish Disease Detector API
After=network.target

[Service]
Type=simple
User=pi
WorkingDirectory=/home/pi/catfish_detector
Environment="PATH=/home/pi/tflite_env/bin"
ExecStart=/home/pi/tflite_env/bin/python3 /home/pi/catfish_detector/app.py
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

### 7. Enable and Start Service

```bash
sudo systemctl daemon-reload
sudo systemctl enable catfish-detector
sudo systemctl start catfish-detector
sudo systemctl status catfish-detector
```

## Flutter App Integration

### 1. Configure Raspberry Pi Host

In your Flutter app, update the Raspberry Pi host IP:

```dart
// In your login screen or settings
final rpiService = RaspberryPiService();
await rpiService.initialize(
  host: '192.168.1.100',  // Your Raspberry Pi IP
  port: 5000,
);
```

### 2. Use Image Stream

```dart
// In dual_stream_monitoring_screen.dart
final rpiService = RaspberryPiService();
rpiService.getImageStream().listen((imageBase64) {
  // Display image in your camera view
  setState(() {
    _currentImage = imageBase64;
  });
});
```

### 3. Capture and Detect

```dart
// Capture image and run detection
final imageBase64 = await rpiService.captureImage();
if (imageBase64 != null) {
  final result = await rpiService.detectDisease(imageBase64);
  // Process detection result
}
```

## Network Configuration

### Find Raspberry Pi IP Address

```bash
# On Raspberry Pi
hostname -I

# Or on your computer
ping raspberrypi.local
```

### Firewall Configuration

```bash
# Allow port 5000
sudo ufw allow 5000/tcp
sudo ufw enable
```

## Troubleshooting

### Camera Not Detected
```bash
# Check camera connection
vcgencmd get_camera

# List connected cameras
libcamera-hello --list-cameras
```

### API Connection Issues
```bash
# Test API from Raspberry Pi
curl http://localhost:5000/health

# Test from another device
curl http://192.168.1.100:5000/health
```

### TensorFlow Lite Issues
```bash
# Verify installation
python3 -c "import tflite_runtime; print('OK')"
```

## Model Preparation

1. **Train your model** using TensorFlow/Keras
2. **Convert to TFLite format**:
```python
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()
with open('model.tflite', 'wb') as f:
    f.write(tflite_model)
```
3. **Copy to Raspberry Pi**:
```bash
scp model.tflite pi@192.168.1.100:/home/pi/catfish_detector/
```

## Performance Optimization

- Use quantized models for faster inference
- Reduce image resolution if needed
- Use threading for image capture
- Cache model in memory

## Security Considerations

- Use HTTPS in production
- Implement API authentication
- Restrict network access
- Keep Raspberry Pi OS updated
