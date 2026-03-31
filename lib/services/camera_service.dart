import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;

class CameraService {
  static final CameraService _instance = CameraService._internal();
  CameraController? _controller;
  List<CameraDescription>? _cameras;

  factory CameraService() {
    return _instance;
  }

  CameraService._internal();

  // Initialize cameras
  Future<void> initializeCameras() async {
    try {
      _cameras = await availableCameras();
    } catch (e) {
      print('Error initializing cameras: $e');
    }
  }

  // Get available cameras
  List<CameraDescription>? get cameras => _cameras;

  // Initialize camera controller
  Future<CameraController?> initializeCamera({int cameraIndex = 0}) async {
    if (_cameras == null || _cameras!.isEmpty) {
      await initializeCameras();
    }

    if (_cameras == null || _cameras!.isEmpty) {
      throw Exception('No cameras available');
    }

    if (cameraIndex >= _cameras!.length) {
      cameraIndex = 0;
    }

    _controller = CameraController(
      _cameras![cameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await _controller!.initialize();
    return _controller;
  }

  // Get current controller
  CameraController? get controller => _controller;

  // Capture image and return as bytes
  Future<Uint8List> captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      throw Exception('Camera not initialized');
    }

    final XFile image = await _controller!.takePicture();
    final bytes = await image.readAsBytes();
    
    return bytes;
  }

  // Capture and save image to local storage
  Future<String> captureAndSaveImage({String? customName}) async {
    if (_controller == null || !_controller!.value.isInitialized) {
      throw Exception('Camera not initialized');
    }

    final XFile image = await _controller!.takePicture();
    
    // Get app documents directory
    final directory = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${directory.path}/catfish_images');
    
    // Create directory if it doesn't exist
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    // Generate filename
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename = customName ?? 'catfish_$timestamp.jpg';
    final filePath = path.join(imagesDir.path, filename);

    // Copy image to permanent location
    await File(image.path).copy(filePath);
    
    return filePath;
  }

  // Capture image and return both bytes and file path
  Future<Map<String, dynamic>> captureImageComplete({String? customName}) async {
    if (_controller == null || !_controller!.value.isInitialized) {
      throw Exception('Camera not initialized');
    }

    final XFile image = await _controller!.takePicture();
    final bytes = await image.readAsBytes();
    
    // Get app documents directory
    final directory = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${directory.path}/catfish_images');
    
    // Create directory if it doesn't exist
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    // Generate filename
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename = customName ?? 'catfish_$timestamp.jpg';
    final filePath = path.join(imagesDir.path, filename);

    // Copy image to permanent location
    await File(image.path).copy(filePath);
    
    return {
      'bytes': bytes,
      'path': filePath,
      'filename': filename,
    };
  }

  // Compress image for storage
  Future<Uint8List> compressImage(Uint8List bytes, {int quality = 85}) async {
    final image = img.decodeImage(bytes);
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Resize if too large (max 1280px width)
    img.Image resized = image;
    if (image.width > 1280) {
      resized = img.copyResize(image, width: 1280);
    }

    // Encode as JPEG with quality setting
    final compressed = img.encodeJpg(resized, quality: quality);
    return Uint8List.fromList(compressed);
  }

  // Capture from network camera (Raspberry Pi)
  Future<Uint8List?> captureFromNetworkCamera(String url) async {
    try {
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(Uri.parse(url));
      final response = await request.close();
      
      if (response.statusCode == 200) {
        final bytes = await _consolidateBytes(response);
        return bytes;
      } else {
        throw Exception('Failed to capture from network camera: ${response.statusCode}');
      }
    } catch (e) {
      print('Error capturing from network camera: $e');
      return null;
    }
  }

  // Helper method to consolidate HTTP response bytes
  Future<Uint8List> _consolidateBytes(HttpClientResponse response) async {
    final List<int> bytes = [];
    await for (var chunk in response) {
      bytes.addAll(chunk);
    }
    return Uint8List.fromList(bytes);
  }

  // Save network camera image
  Future<String?> saveNetworkCameraImage(String url, {String? customName}) async {
    try {
      final bytes = await captureFromNetworkCamera(url);
      if (bytes == null) return null;

      // Get app documents directory
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/catfish_images');
      
      // Create directory if it doesn't exist
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // Generate filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = customName ?? 'network_catfish_$timestamp.jpg';
      final filePath = path.join(imagesDir.path, filename);

      // Save image
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      
      return filePath;
    } catch (e) {
      print('Error saving network camera image: $e');
      return null;
    }
  }

  // Dispose camera controller
  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
  }

  // Switch camera (front/back)
  Future<CameraController?> switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) {
      throw Exception('No additional cameras available');
    }

    await dispose();

    // Find next camera
    final currentIndex = _cameras!.indexOf(_controller!.description);
    final nextIndex = (currentIndex + 1) % _cameras!.length;

    return await initializeCamera(cameraIndex: nextIndex);
  }
}
