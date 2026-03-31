import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/camera_service.dart';
import '../services/network_camera_service.dart';
import '../models/detection_data.dart';
import '../widgets/live_indicator.dart';

class EnhancedMonitoringScreen extends StatefulWidget {
  const EnhancedMonitoringScreen({super.key});

  @override
  State<EnhancedMonitoringScreen> createState() => _EnhancedMonitoringScreenState();
}

class _EnhancedMonitoringScreenState extends State<EnhancedMonitoringScreen> {
  final CameraService _cameraService = CameraService();
  final NetworkCameraService _networkCameraService = NetworkCameraService();
  
  CameraController? _cameraController;
  VideoPlayerController? _videoController;
  
  bool _useRPiCamera = false;
  bool _isInitialized = false;
  bool _isLive = false;
  
  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }
  
  Future<void> _initializeCamera() async {
    if (_useRPiCamera) {
      await _initializeRPiCamera();
    } else {
      await _initializeMobileCamera();
    }
  }
  
  Future<void> _initializeMobileCamera() async {
    try {
      await _cameraService.initializeCameras();
      _cameraController = await _cameraService.initializeCamera();
      if (_cameraController != null) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing mobile camera: $e');
    }
  }
  
  Future<void> _initializeRPiCamera() async {
    try {
      _videoController = await _networkCameraService.initializeVideoStream();
      if (_videoController != null) {
        setState(() {
          _isInitialized = true;
        });
        _videoController!.play();
      }
    } catch (e) {
      print('Error initializing RPi camera: $e');
    }
  }
  
  void _toggleCameraSource() {
    setState(() {
      _useRPiCamera = !_useRPiCamera;
      _isInitialized = false;
      _isLive = false;
    });
    
    // Dispose current controller
    _cameraController?.dispose();
    _videoController?.dispose();
    
    // Initialize new camera
    _initializeCamera();
  }
  
  void _toggleLiveMonitoring() {
    setState(() {
      _isLive = !_isLive;
    });
    
    if (_isLive) {
      _startLiveMonitoring();
    } else {
      _stopLiveMonitoring();
    }
  }
  
  void _startLiveMonitoring() {
    // Start real-time disease detection
    // This would integrate with your AI detection service
    print('Starting live monitoring...');
  }
  
  void _stopLiveMonitoring() {
    // Stop real-time detection
    print('Stopping live monitoring...');
  }
  
  Future<void> _captureImage() async {
    if (_useRPiCamera) {
      final filename = await _networkCameraService.captureImage();
      if (filename != null) {
        // Process captured image for disease detection
        _processImage(filename);
      }
    } else if (_cameraController != null) {
      final image = await _cameraController!.takePicture();
      _processImage(image.path);
    }
  }
  
  void _processImage(String imagePath) {
    // Add detection logic here
    final detection = DetectionData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      diseaseType: 'Healthy',
      confidence: 95.0,
      timestamp: DateTime.now(),
      imagePath: imagePath,
      status: 'healthy',
    );
    
    Provider.of<DetectionProvider>(context, listen: false).addDetection(detection);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Image captured: ${detection.diseaseType}'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  @override
  void dispose() {
    _cameraController?.dispose();
    _videoController?.dispose();
    _networkCameraService.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.monitor_heart),
            const SizedBox(width: 8),
            const Text('Enhanced Monitoring'),
            if (_useRPiCamera) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'RPi',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            onPressed: _toggleCameraSource,
            icon: Icon(_useRPiCamera ? Icons.phone_iphone : Icons.router),
            tooltip: _useRPiCamera ? 'Switch to Mobile' : 'Switch to RPi',
          ),
          IconButton(
            onPressed: () {
              _showRPiSettings();
            },
            icon: const Icon(Icons.settings),
            tooltip: 'RPi Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          // Camera View
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.black,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _buildCameraView(),
              ),
            ),
          ),
          
          // Controls
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Live Status
                Row(
                  children: [
                    LiveIndicator(isLive: _isLive),
                    const SizedBox(width: 12),
                    Text(
                      _isLive ? 'Live Monitoring Active' : 'Monitoring Paused',
                      style: TextStyle(
                        color: _isLive ? Colors.green : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Switch(
                      value: _isLive,
                      onChanged: (_) => _toggleLiveMonitoring(),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _captureImage,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Capture'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isLive ? _toggleLiveMonitoring : null,
                        icon: Icon(_isLive ? Icons.stop : Icons.play_arrow),
                        label: Text(_isLive ? 'Stop' : 'Start'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCameraView() {
    if (!_isInitialized) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Initializing Camera...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }
    
    if (_useRPiCamera && _videoController != null) {
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _videoController!.value.size.width,
          height: _videoController!.value.size.height,
          child: VideoPlayer(_videoController!),
        ),
      );
    }
    
    if (!_useRPiCamera && _cameraController != null) {
      return CameraPreview(_cameraController!);
    }
    
    return const Center(
      child: Text(
        'Camera Error',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
  
  void _showRPiSettings() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: RPICameraSettings(),
        ),
      ),
    );
  }
}
