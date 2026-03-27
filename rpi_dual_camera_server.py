#!/usr/bin/env python3
"""
Dual Camera Server for Raspberry Pi 5
Supports 2 cameras with AI disease detection
"""

from flask import Flask, Response, jsonify, request
from picamera2 import Picamera2
import cv2
import numpy as np
import threading
import time
from datetime import datetime
import base64

app = Flask(__name__)

# Initialize both cameras
camera1 = None
camera2 = None
camera_lock = threading.Lock()

# AI Model placeholder (you'll load your trained model here)
ai_model = None
detection_enabled = True

def initialize_cameras():
    """Initialize both cameras on Raspberry Pi 5"""
    global camera1, camera2
    
    try:
        # Get available cameras
        cameras = Picamera2.global_camera_info()
        print(f"Found {len(cameras)} cameras")
        
        if len(cameras) >= 1:
            # Initialize Camera 1
            camera1 = Picamera2(0)
            config1 = camera1.create_preview_configuration(
                main={"size": (640, 480), "format": "RGB888"}
            )
            camera1.configure(config1)
            camera1.start()
            print("Camera 1 initialized")
        
        if len(cameras) >= 2:
            # Initialize Camera 2
            camera2 = Picamera2(1)
            config2 = camera2.create_preview_configuration(
                main={"size": (640, 480), "format": "RGB888"}
            )
            camera2.configure(config2)
            camera2.start()
            print("Camera 2 initialized")
        
        # Wait for cameras to warm up
        time.sleep(2)
        
    except Exception as e:
        print(f"Error initializing cameras: {e}")

def load_ai_model():
    """Load your trained AI model for disease detection"""
    global ai_model
    
    # TODO: Load your actual trained model
    # Example for TensorFlow/Keras:
    # from tensorflow import keras
    # ai_model = keras.models.load_model('/path/to/your/model.h5')
    
    # Example for PyTorch:
    # import torch
    # ai_model = torch.load('/path/to/your/model.pth')
    # ai_model.eval()
    
    print("AI Model loaded (placeholder)")
    return True

def detect_disease(frame):
    """
    Run AI disease detection on frame
    Returns: dict with detection results
    """
    if not detection_enabled or ai_model is None:
        return None
    
    try:
        # TODO: Implement your actual AI detection here
        # This is a placeholder that simulates detection
        
        # Preprocess frame for your model
        # processed = preprocess_image(frame)
        
        # Run inference
        # predictions = ai_model.predict(processed)
        
        # For now, return mock detection (replace with real detection)
        # Simulate random detection for demonstration
        import random
        if random.random() > 0.7:  # 30% chance of detection
            diseases = ['Columnaris', 'Ich', 'Fin Rot', 'Healthy']
            disease = random.choice(diseases)
            confidence = random.uniform(0.65, 0.95)
            
            return {
                'detected': disease != 'Healthy',
                'disease': disease,
                'confidence': confidence,
                'timestamp': datetime.now().isoformat(),
                'severity': 'critical' if confidence > 0.85 else 'moderate'
            }
        
        return None
        
    except Exception as e:
        print(f"Error in disease detection: {e}")
        return None

def draw_detection_overlay(frame, detection):
    """Draw AI detection results on frame"""
    if detection and detection['detected']:
        # Draw bounding box (you can customize based on your model output)
        height, width = frame.shape[:2]
        
        # Draw red rectangle for disease detection
        cv2.rectangle(frame, (10, 10), (width-10, 100), (0, 0, 255), 2)
        
        # Add disease name
        text = f"{detection['disease']}"
        cv2.putText(frame, text, (20, 40), 
                   cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 0, 255), 2)
        
        # Add confidence
        conf_text = f"Confidence: {detection['confidence']:.1%}"
        cv2.putText(frame, conf_text, (20, 70), 
                   cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 0, 255), 2)
        
        # Add severity indicator
        severity_color = (0, 0, 255) if detection['severity'] == 'critical' else (0, 165, 255)
        cv2.circle(frame, (width-30, 30), 15, severity_color, -1)
    
    # Add timestamp
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    cv2.putText(frame, timestamp, (10, height-10), 
               cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)
    
    return frame

def generate_frames(camera_num):
    """Generate video frames from specified camera with AI detection"""
    camera = camera1 if camera_num == 1 else camera2
    
    if camera is None:
        # Return error frame
        error_frame = np.zeros((480, 640, 3), dtype=np.uint8)
        cv2.putText(error_frame, f"Camera {camera_num} not available", 
                   (50, 240), cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 255, 255), 2)
        ret, buffer = cv2.imencode('.jpg', error_frame)
        yield (b'--frame\r\n'
               b'Content-Type: image/jpeg\r\n\r\n' + buffer.tobytes() + b'\r\n')
        return
    
    while True:
        try:
            with camera_lock:
                # Capture frame
                frame = camera.capture_array()
                
                # Convert RGB to BGR for OpenCV
                frame = cv2.cvtColor(frame, cv2.COLOR_RGB2BGR)
                
                # Run AI detection
                detection = detect_disease(frame)
                
                # Draw detection overlay
                frame = draw_detection_overlay(frame, detection)
                
                # Add camera label
                cv2.putText(frame, f"Camera {camera_num}", (10, 30), 
                           cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)
                
                # Encode frame as JPEG
                ret, buffer = cv2.imencode('.jpg', frame, 
                                          [cv2.IMWRITE_JPEG_QUALITY, 85])
                frame_bytes = buffer.tobytes()
                
                yield (b'--frame\r\n'
                       b'Content-Type: image/jpeg\r\n\r\n' + frame_bytes + b'\r\n')
                
        except Exception as e:
            print(f"Error generating frame from camera {camera_num}: {e}")
            time.sleep(0.1)

@app.route('/')
def index():
    """API information"""
    return jsonify({
        'service': 'Catfish Disease Detector - Dual Camera Server',
        'version': '1.0',
        'cameras': {
            'camera1': camera1 is not None,
            'camera2': camera2 is not None
        },
        'endpoints': {
            'camera1_feed': '/camera1/video_feed',
            'camera2_feed': '/camera2/video_feed',
            'camera1_capture': '/camera1/capture',
            'camera2_capture': '/camera2/capture',
            'detection_toggle': '/detection/toggle',
            'status': '/status'
        }
    })

@app.route('/camera1/video_feed')
def camera1_feed():
    """Camera 1 video stream with AI detection"""
    return Response(generate_frames(1),
                   mimetype='multipart/x-mixed-replace; boundary=frame')

@app.route('/camera2/video_feed')
def camera2_feed():
    """Camera 2 video stream with AI detection"""
    return Response(generate_frames(2),
                   mimetype='multipart/x-mixed-replace; boundary=frame')

@app.route('/camera1/capture')
def camera1_capture():
    """Capture single frame from camera 1"""
    if camera1 is None:
        return jsonify({'error': 'Camera 1 not available'}), 404
    
    try:
        with camera_lock:
            frame = camera1.capture_array()
            frame = cv2.cvtColor(frame, cv2.COLOR_RGB2BGR)
            
            # Run AI detection
            detection = detect_disease(frame)
            
            # Draw overlay
            frame = draw_detection_overlay(frame, detection)
            
            # Encode as JPEG
            ret, buffer = cv2.imencode('.jpg', frame)
            
            return Response(buffer.tobytes(), mimetype='image/jpeg')
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/camera2/capture')
def camera2_capture():
    """Capture single frame from camera 2"""
    if camera2 is None:
        return jsonify({'error': 'Camera 2 not available'}), 404
    
    try:
        with camera_lock:
            frame = camera2.capture_array()
            frame = cv2.cvtColor(frame, cv2.COLOR_RGB2BGR)
            
            # Run AI detection
            detection = detect_disease(frame)
            
            # Draw overlay
            frame = draw_detection_overlay(frame, detection)
            
            # Encode as JPEG
            ret, buffer = cv2.imencode('.jpg', frame)
            
            return Response(buffer.tobytes(), mimetype='image/jpeg')
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/detection/toggle', methods=['POST'])
def toggle_detection():
    """Enable/disable AI detection"""
    global detection_enabled
    detection_enabled = not detection_enabled
    return jsonify({
        'detection_enabled': detection_enabled,
        'message': f"AI detection {'enabled' if detection_enabled else 'disabled'}"
    })

@app.route('/status')
def status():
    """Get server status"""
    return jsonify({
        'cameras': {
            'camera1': {
                'available': camera1 is not None,
                'resolution': '640x480' if camera1 else None
            },
            'camera2': {
                'available': camera2 is not None,
                'resolution': '640x480' if camera2 else None
            }
        },
        'ai_detection': {
            'enabled': detection_enabled,
            'model_loaded': ai_model is not None
        },
        'timestamp': datetime.now().isoformat()
    })

if __name__ == '__main__':
    print("=" * 60)
    print("Catfish Disease Detector - Dual Camera Server")
    print("=" * 60)
    
    # Initialize cameras
    print("\nInitializing cameras...")
    initialize_cameras()
    
    # Load AI model
    print("\nLoading AI model...")
    load_ai_model()
    
    print("\n" + "=" * 60)
    print("Server starting on http://0.0.0.0:5000")
    print("=" * 60)
    print("\nEndpoints:")
    print("  Camera 1 Feed: http://<raspberry-pi-ip>:5000/camera1/video_feed")
    print("  Camera 2 Feed: http://<raspberry-pi-ip>:5000/camera2/video_feed")
    print("  Camera 1 Capture: http://<raspberry-pi-ip>:5000/camera1/capture")
    print("  Camera 2 Capture: http://<raspberry-pi-ip>:5000/camera2/capture")
    print("  Status: http://<raspberry-pi-ip>:5000/status")
    print("=" * 60 + "\n")
    
    # Run Flask server
    app.run(host='0.0.0.0', port=5000, threaded=True, debug=False)
