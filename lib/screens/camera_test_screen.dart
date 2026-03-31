import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/camera_service.dart';

class CameraTestScreen extends StatefulWidget {
  const CameraTestScreen({super.key});

  @override
  State<CameraTestScreen> createState() => _CameraTestScreenState();
}

class _CameraTestScreenState extends State<CameraTestScreen> {
  final CameraService _cameraService = CameraService();
  CameraController? _controller;
  bool _isInitialized = false;
  String _statusMessage = 'Initializing camera...';
  List<CameraDescription>? _cameras;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      setState(() {
        _statusMessage = 'Getting available cameras...';
      });

      // Get available cameras
      _cameras = await availableCameras();
      
      setState(() {
        _statusMessage = 'Found ${_cameras?.length ?? 0} cameras';
      });

      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          _statusMessage = 'No cameras found!';
        });
        return;
      }

      setState(() {
        _statusMessage = 'Initializing camera controller...';
      });

      // Initialize camera controller
      _controller = CameraController(
        _cameras![0],
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();

      setState(() {
        _isInitialized = true;
        _statusMessage = 'Camera ready!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
      });
      print('Camera initialization error: $e');
    }
  }

  Future<void> _captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera not initialized')),
      );
      return;
    }

    try {
      final image = await _controller!.takePicture();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image captured: ${image.path}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Capture failed: $e')),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Test'),
        backgroundColor: const Color(0xFF0277BD),
      ),
      body: Column(
        children: [
          // Status Message
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: _isInitialized ? Colors.green.shade100 : Colors.orange.shade100,
            child: Text(
              _statusMessage,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _isInitialized ? Colors.green.shade900 : Colors.orange.shade900,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Camera Info
          if (_cameras != null && _cameras!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Available Cameras:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ..._cameras!.asMap().entries.map((entry) {
                    final index = entry.key;
                    final camera = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        '${index + 1}. ${camera.name} (${camera.lensDirection})',
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),

          // Camera Preview
          Expanded(
            child: _isInitialized && _controller != null
                ? CameraPreview(_controller!)
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(_statusMessage),
                      ],
                    ),
                  ),
          ),

          // Controls
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isInitialized ? _captureImage : null,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Capture'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0277BD),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _controller?.dispose();
                    _controller = null;
                    setState(() {
                      _isInitialized = false;
                    });
                    _initializeCamera();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
