# Dual Camera AI Setup for Raspberry Pi 5

## 🎯 Your Setup: 2 Cameras + AI Disease Detection

This guide will help you set up your Raspberry Pi 5 with 2 cameras for live monitoring with real-time AI disease detection.

## 📋 Hardware Checklist

- ✅ Raspberry Pi 5
- ✅ 2x Camera modules (connected to CSI ports)
- ✅ MicroSD card (32GB+ recommended)
- ✅ Power supply
- ✅ Network connection (WiFi or Ethernet)

## 🚀 Quick Setup (10 Minutes)

### Step 1: Connect Both Cameras to Raspberry Pi 5

Raspberry Pi 5 has 2 CSI camera connectors:
1. **Camera 0**: Main camera port (near HDMI)
2. **Camera 1**: Secondary camera port

Connect your cameras to both ports.

### Step 2: Enable Cameras

```bash
# SSH into your Raspberry Pi or use terminal
sudo raspi-config

# Navigate to:
# Interface Options > Camera > Enable

# Reboot
sudo reboot
```

### Step 3: Verify Both Cameras

```bash
# Check if both cameras are detected
libcamera-hello --list-cameras

# Should show:
# Available cameras
# 0 : imx219 [3280x2464] (/base/axi/pcie@120000/rp1/i2c@80000/imx219@10)
# 1 : imx219 [3280x2464] (/base/axi/pcie@120000/rp1/i2c@88000/imx219@10)

# Test Camera 0
libcamera-hello --camera 0 -t 5000

# Test Camera 1
libcamera-hello --camera 1 -t 5000
```

### Step 4: Install Required Packages

```bash
# Update system
sudo apt-get update
sudo apt-get upgrade -y

# Install Python packages
sudo apt-get install -y python3-pip python3-opencv python3-numpy
pip3 install flask picamera2 opencv-python numpy

# For AI model support (TensorFlow)
pip3 install tensorflow-lite-runtime

# Or for PyTorch
# pip3 install torch torchvision
```

### Step 5: Upload Dual Camera Server Script

```bash
# Create directory
mkdir -p ~/catfish_monitor
cd ~/catfish_monitor

# Upload the rpi_dual_camera_server.py file to this directory
# You can use scp, FileZilla, or copy-paste

# Make it executable
chmod +x rpi_dual_camera_server.py
```

### Step 6: Add Your AI Model

```bash
# Create models directory
mkdir -p ~/catfish_monitor/models

# Upload your trained AI model
# Example: catfish_disease_model.h5 or catfish_model.tflite
```

Update the `load_ai_model()` function in `rpi_dual_camera_server.py`:

```python
def load_ai_model():
    """Load your trained AI model"""
    global ai_model
    
    # For TensorFlow Lite
    import tflite_runtime.interpreter as tflite
    ai_model = tflite.Interpreter(model_path='models/catfish_model.tflite')
    ai_model.allocate_tensors()
    
    # For TensorFlow/Keras
    # from tensorflow import keras
    # ai_model = keras.models.load_model('models/catfish_disease_model.h5')
    
    print("AI Model loaded successfully")
    return True
```

Update the `detect_disease()` function with your actual detection logic:

```python
def detect_disease(frame):
    """Run AI disease detection on frame"""
    if not detection_enabled or ai_model is None:
        return None
    
    try:
        # Preprocess frame for your model
        input_size = (224, 224)  # Adjust to your model's input size
        processed = cv2.resize(frame, input_size)
        processed = processed / 255.0  # Normalize
        processed = np.expand_dims(processed, axis=0)
        
        # Run inference (TensorFlow Lite example)
        input_details = ai_model.get_input_details()
        output_details = ai_model.get_output_details()
        
        ai_model.set_tensor(input_details[0]['index'], processed.astype(np.float32))
        ai_model.invoke()
        predictions = ai_model.get_tensor(output_details[0]['index'])[0]
        
        # Get disease class
        disease_classes = ['Healthy', 'Columnaris', 'Ich', 'Fin Rot', 'Fungal']
        disease_idx = np.argmax(predictions)
        confidence = float(predictions[disease_idx])
        
        if confidence > 0.6:  # Confidence threshold
            return {
                'detected': disease_idx != 0,  # 0 = Healthy
                'disease': disease_classes[disease_idx],
                'confidence': confidence,
                'timestamp': datetime.now().isoformat(),
                'severity': 'critical' if confidence > 0.85 else 'moderate'
            }
        
        return None
        
    except Exception as e:
        print(f"Error in disease detection: {e}")
        return None
```

### Step 7: Run the Server

```bash
# Test run
python3 rpi_dual_camera_server.py

# You should see:
# ============================================================
# Catfish Disease Detector - Dual Camera Server
# ============================================================
# 
# Initializing cameras...
# Found 2 cameras
# Camera 1 initialized
# Camera 2 initialized
# 
# Loading AI model...
# AI Model loaded successfully
# 
# ============================================================
# Server starting on http://0.0.0.0:5000
# ============================================================
```

### Step 8: Get Raspberry Pi IP Address

```bash
hostname -I
# Example output: 192.168.1.100
```

### Step 9: Test Camera Feeds

Open browser on your phone/computer:
- **Camera 1**: `http://192.168.1.100:5000/camera1/video_feed`
- **Camera 2**: `http://192.168.1.100:5000/camera2/video_feed`
- **Status**: `http://192.168.1.100:5000/status`

You should see both camera feeds with AI detection overlay!

### Step 10: Auto-Start on Boot

```bash
# Create systemd service
sudo nano /etc/systemd/system/catfish-camera.service
```

Add this content:

```ini
[Unit]
Description=Catfish Disease Detector Dual Camera Server
After=network.target

[Service]
Type=simple
User=pi
WorkingDirectory=/home/pi/catfish_monitor
ExecStart=/usr/bin/python3 /home/pi/catfish_monitor/rpi_dual_camera_server.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Enable and start:

```bash
sudo systemctl enable catfish-camera.service
sudo systemctl start catfish-camera.service

# Check status
sudo systemctl status catfish-camera.service

# View logs
sudo journalctl -u catfish-camera.service -f
```

## 📱 Configure the App

### In the Dual Stream Monitoring Screen:

1. **Camera 1 URL**: `http://192.168.1.100:5000/camera1/video_feed`
2. **Camera 2 URL**: `http://192.168.1.100:5000/camera2/video_feed`

The app will show:
- ✅ Live feed from both cameras
- ✅ Real-time AI disease detection overlay
- ✅ Disease name and confidence percentage
- ✅ Severity indicator (red circle for critical)
- ✅ Timestamp on each frame

## 🤖 AI Model Integration

### Supported Frameworks:

1. **TensorFlow Lite** (Recommended for Raspberry Pi)
   - Fastest inference
   - Optimized for ARM processors
   - Convert your model: `model.tflite`

2. **TensorFlow/Keras**
   - Full TensorFlow support
   - Model format: `.h5` or SavedModel

3. **PyTorch**
   - Good performance
   - Model format: `.pth` or `.pt`

### Model Requirements:

- **Input**: RGB image (e.g., 224x224 or 640x480)
- **Output**: Disease class probabilities
- **Classes**: Define your disease categories
  - Example: `['Healthy', 'Columnaris', 'Ich', 'Fin Rot', 'Fungal']`

### Training Your Model:

If you haven't trained a model yet, here's a quick guide:

```python
# Example using TensorFlow/Keras
import tensorflow as tf
from tensorflow import keras

# Load your dataset
# X_train: images, y_train: labels

# Create model
model = keras.Sequential([
    keras.layers.Conv2D(32, 3, activation='relu', input_shape=(224, 224, 3)),
    keras.layers.MaxPooling2D(),
    keras.layers.Conv2D(64, 3, activation='relu'),
    keras.layers.MaxPooling2D(),
    keras.layers.Conv2D(128, 3, activation='relu'),
    keras.layers.MaxPooling2D(),
    keras.layers.Flatten(),
    keras.layers.Dense(128, activation='relu'),
    keras.layers.Dropout(0.5),
    keras.layers.Dense(5, activation='softmax')  # 5 classes
])

# Compile
model.compile(
    optimizer='adam',
    loss='categorical_crossentropy',
    metrics=['accuracy']
)

# Train
model.fit(X_train, y_train, epochs=50, validation_split=0.2)

# Save
model.save('catfish_disease_model.h5')

# Convert to TFLite for Raspberry Pi
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()
with open('catfish_model.tflite', 'wb') as f:
    f.write(tflite_model)
```

## 🎨 AI Detection Overlay Features

The server automatically draws on the video feed:

1. **Disease Detection Box** (Red rectangle)
   - Shows when disease is detected
   - Contains disease name and confidence

2. **Confidence Percentage**
   - Shows AI model's confidence level
   - Example: "Confidence: 87.5%"

3. **Severity Indicator** (Colored circle)
   - Red: Critical (confidence > 85%)
   - Orange: Moderate (confidence 60-85%)

4. **Timestamp**
   - Bottom left corner
   - Format: YYYY-MM-DD HH:MM:SS

5. **Camera Label**
   - Top left: "Camera 1" or "Camera 2"

## 🔧 API Endpoints

Your Raspberry Pi server provides these endpoints:

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Server info and available endpoints |
| `/camera1/video_feed` | GET | Camera 1 live stream with AI |
| `/camera2/video_feed` | GET | Camera 2 live stream with AI |
| `/camera1/capture` | GET | Capture single frame from Camera 1 |
| `/camera2/capture` | GET | Capture single frame from Camera 2 |
| `/detection/toggle` | POST | Enable/disable AI detection |
| `/status` | GET | Server and camera status |

### Example API Usage:

```bash
# Get status
curl http://192.168.1.100:5000/status

# Toggle AI detection
curl -X POST http://192.168.1.100:5000/detection/toggle

# Capture from Camera 1
curl http://192.168.1.100:5000/camera1/capture > capture1.jpg
```

## 📊 Performance Optimization

### For Better FPS:

1. **Reduce Resolution**:
   ```python
   config = camera.create_preview_configuration(
       main={"size": (320, 240), "format": "RGB888"}
   )
   ```

2. **Lower JPEG Quality**:
   ```python
   cv2.imencode('.jpg', frame, [cv2.IMWRITE_JPEG_QUALITY, 70])
   ```

3. **Skip Frames for AI**:
   ```python
   frame_count = 0
   if frame_count % 5 == 0:  # Run AI every 5 frames
       detection = detect_disease(frame)
   frame_count += 1
   ```

### Expected Performance:

- **Raspberry Pi 5**: 15-30 FPS per camera with AI
- **With TFLite**: 20-30 FPS
- **With Full TensorFlow**: 10-15 FPS

## 🔍 Troubleshooting

### Camera Not Detected:

```bash
# Check camera connections
vcgencmd get_camera

# Should show: supported=1 detected=1

# List cameras
libcamera-hello --list-cameras
```

### Server Won't Start:

```bash
# Check Python version (need 3.9+)
python3 --version

# Reinstall packages
pip3 install --upgrade flask picamera2 opencv-python

# Check logs
sudo journalctl -u catfish-camera.service -n 50
```

### AI Detection Not Working:

```bash
# Check if model file exists
ls -lh ~/catfish_monitor/models/

# Test model loading separately
python3 -c "import tensorflow as tf; print(tf.__version__)"

# Check server logs for errors
tail -f /var/log/syslog | grep catfish
```

### Poor Detection Accuracy:

- Ensure good lighting on fish
- Clean camera lens
- Retrain model with more data
- Adjust confidence threshold
- Check preprocessing matches training

## 💡 Tips for Best Results

### Camera Positioning:
- Mount 30-50cm above water surface
- Angle slightly downward (15-30 degrees)
- Ensure even lighting
- Avoid direct sunlight causing glare

### Lighting:
- Use LED lights for consistent illumination
- 24/7 monitoring needs waterproof LED strips
- Color temperature: 5000-6500K (daylight)

### Model Training:
- Collect 500+ images per disease class
- Include various lighting conditions
- Capture different fish sizes and angles
- Balance dataset (equal samples per class)
- Use data augmentation

## 🌐 Network Setup

### Local Network (Offline):

Your setup works completely offline on local network:

1. Connect Raspberry Pi to router via Ethernet or WiFi
2. Connect Android device to same network
3. Use local IP address (192.168.x.x)
4. No internet required!

### Access Point Mode:

Make Raspberry Pi create its own WiFi network:

```bash
# Install packages
sudo apt-get install hostapd dnsmasq

# Configure as described in RASPBERRY_PI_CAMERA_SETUP.md
```

## 📈 Next Steps

1. ✅ Verify both cameras working
2. ✅ Test AI detection with your model
3. ✅ Configure app with camera URLs
4. ✅ Monitor your catfish pond!
5. 📊 Collect detection data
6. 🔄 Improve model with new data
7. 📱 Share results with other farmers

## 🎉 You're All Set!

Your dual camera AI system is ready to monitor your catfish 24/7 with real-time disease detection!

**Camera URLs for your app:**
- Camera 1: `http://192.168.1.100:5000/camera1/video_feed`
- Camera 2: `http://192.168.1.100:5000/camera2/video_feed`

Happy monitoring! 🐟📸🤖
