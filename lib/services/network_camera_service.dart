import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';

class NetworkCameraService {
  static final NetworkCameraService _instance =
      NetworkCameraService._internal();
  factory NetworkCameraService() => _instance;
  NetworkCameraService._internal();

  VideoPlayerController? _videoController;
  String _rpiServerUrl =
      'http://192.168.100.113:5000'; // Default RPi IP - CHANGE THIS TO YOUR RPI IP

  // Set RPi server URL
  void setServerUrl(String url) {
    _rpiServerUrl =
        url.replaceAll('https:', 'http:'); // Ensure http for local network
  }

  // Get current server URL
  String get serverUrl => _rpiServerUrl;

  // Get video feed URL for camera 1
  String getVideoFeed1Url() => '$_rpiServerUrl/video_feed1';

  // Get video feed URL for camera 2 (if available)
  String getVideoFeed2Url() => '$_rpiServerUrl/video_feed2';

  // Initialize video stream from RPi
  Future<VideoPlayerController?> initializeVideoStream(
      {int cameraNumber = 1}) async {
    try {
      // For MJPEG stream - use video_feed1 or video_feed2
      final streamUrl = cameraNumber == 1
          ? '$_rpiServerUrl/video_feed1'
          : '$_rpiServerUrl/video_feed2';
      _videoController = VideoPlayerController.networkUrl(Uri.parse(streamUrl));
      await _videoController!.initialize();
      return _videoController;
    } catch (e) {
      print('Error initializing video stream: $e');
      return null;
    }
  }

  // Capture still image from RPi camera
  Future<String?> captureImage({int cameraNumber = 1}) async {
    try {
      // Step 1: Trigger capture on RPi server
      final endpoint = cameraNumber == 1 ? '/capture' : '/capture2';
      final captureResponse =
          await http.get(Uri.parse('$_rpiServerUrl$endpoint'));

      if (captureResponse.statusCode == 200) {
        final data = json.decode(captureResponse.body);
        if (data['success'] == true) {
          final filename = data['filename'];

          // Step 2: Download the captured image
          final imageUrl = '$_rpiServerUrl/images/$filename';
          final imageResponse = await http.get(Uri.parse(imageUrl));

          if (imageResponse.statusCode == 200) {
            // Step 3: Save image to local device storage
            final directory = await getApplicationDocumentsDirectory();
            final imagePath = '${directory.path}/$filename';
            final imageFile = File(imagePath);
            await imageFile.writeAsBytes(imageResponse.bodyBytes);

            print('✅ Image saved locally: $imagePath');
            return imagePath;
          }
        }
      }
      return null;
    } catch (e) {
      print('Error capturing image: $e');
      return null;
    }
  }

  // Get camera status
  Future<Map<String, dynamic>> getCameraStatus() async {
    try {
      final response = await http.get(Uri.parse('$_rpiServerUrl/status'));
      if (response.statusCode == 200) {
        return {
          'connected': true,
          'camera_active': true,
          'resolution': '1920x1080',
          'fps': 30,
        };
      }
    } catch (e) {
      print('Error getting camera status: $e');
    }
    return {
      'connected': false,
      'camera_active': false,
    };
  }

  // Test connection to RPi
  Future<bool> testConnection() async {
    try {
      final response = await http.get(Uri.parse('$_rpiServerUrl/')).timeout(
            const Duration(seconds: 5),
          );
      return response.statusCode == 200;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }

  // Dispose resources
  void dispose() {
    _videoController?.dispose();
    _videoController = null;
  }
}

// RPi Camera Settings Widget
class RPICameraSettings extends StatefulWidget {
  const RPICameraSettings({super.key});

  @override
  State<RPICameraSettings> createState() => _RPICameraSettingsState();
}

class _RPICameraSettingsState extends State<RPICameraSettings> {
  final _urlController =
      TextEditingController(text: 'http://192.168.100.113:5000');
  final NetworkCameraService _cameraService = NetworkCameraService();
  bool _isTesting = false;
  bool _isConnected = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.videocam, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Raspberry Pi Camera',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'RPi Server URL',
                hintText: 'http://192.168.100.113:5000',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: _isTesting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          _isConnected ? Icons.check_circle : Icons.wifi_off),
                  onPressed: _testConnection,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isConnected ? _saveSettings : null,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Settings'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _testConnection,
                    icon: const Icon(Icons.wifi),
                    label: const Text('Test'),
                  ),
                ),
              ],
            ),
            if (_isConnected) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Connected to Raspberry Pi Camera',
                        style: TextStyle(color: Colors.green[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
    });

    final url = _urlController.text.trim();
    _cameraService.setServerUrl(url);
    final connected = await _cameraService.testConnection();

    setState(() {
      _isTesting = false;
      _isConnected = connected;
    });

    if (connected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully connected to RPi camera!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to connect to RPi camera'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _saveSettings() {
    _cameraService.setServerUrl(_urlController.text.trim());
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('RPi camera settings saved')),
    );
  }
}
