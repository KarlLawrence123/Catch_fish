import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RaspberryPiService {
  static final RaspberryPiService _instance = RaspberryPiService._internal();
  
  late String _rpiHost;
  late int _rpiPort;
  bool _isConnected = false;
  final StreamController<String> _imageStreamController = StreamController.broadcast();
  Timer? _pollTimer;

  factory RaspberryPiService() {
    return _instance;
  }

  RaspberryPiService._internal();

  // Initialize connection to Raspberry Pi
  Future<bool> initialize({
    String host = '192.168.1.100',
    int port = 5000,
  }) async {
    _rpiHost = host;
    _rpiPort = port;
    
    try {
      final response = await http.get(
        Uri.parse('http://$_rpiHost:$_rpiPort/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        _isConnected = true;
        _startImagePolling();
        return true;
      }
      return false;
    } catch (e) {
      _isConnected = false;
      return false;
    }
  }

  bool get isConnected => _isConnected;

  // Get stream of images from Raspberry Pi
  Stream<String> getImageStream() {
    return _imageStreamController.stream;
  }

  // Start polling for images from the Raspberry Pi
  void _startImagePolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(milliseconds: 500), (_) async {
      if (_isConnected) {
        await _fetchLatestImage();
      }
    });
  }

  // Fetch latest image from Raspberry Pi
  Future<void> _fetchLatestImage() async {
    try {
      final response = await http.get(
        Uri.parse('http://$_rpiHost:$_rpiPort/api/latest-image'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final imageBase64 = data['image'] as String?;
        if (imageBase64 != null && imageBase64.isNotEmpty) {
          _imageStreamController.add(imageBase64);
        }
      }
    } catch (e) {
      // Silently handle polling errors
    }
  }

  // Capture a single image
  Future<String?> captureImage() async {
    if (!_isConnected) return null;

    try {
      final response = await http.post(
        Uri.parse('http://$_rpiHost:$_rpiPort/api/capture'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['image'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Send image to TensorFlow Lite model for detection
  Future<Map<String, dynamic>?> detectDisease(String imageBase64) async {
    if (!_isConnected) return null;

    try {
      final response = await http.post(
        Uri.parse('http://$_rpiHost:$_rpiPort/api/detect'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'image': imageBase64}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Toggle IR LED for night mode
  Future<bool> toggleIRLED(bool enabled) async {
    if (!_isConnected) return false;

    try {
      final response = await http.post(
        Uri.parse('http://$_rpiHost:$_rpiPort/api/ir-led'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'enabled': enabled}),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Get environmental sensor data (temperature, pH)
  Future<Map<String, dynamic>?> getEnvironmentalData() async {
    if (!_isConnected) return null;

    try {
      final response = await http.get(
        Uri.parse('http://$_rpiHost:$_rpiPort/api/sensors'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Disconnect from Raspberry Pi
  void disconnect() {
    _pollTimer?.cancel();
    _isConnected = false;
  }

  // Dispose resources
  void dispose() {
    _pollTimer?.cancel();
    _imageStreamController.close();
  }
}
