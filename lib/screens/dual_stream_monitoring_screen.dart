import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'dart:math';
import '../models/detection_data.dart';
import '../theme/app_theme.dart';
import '../services/network_camera_service.dart';
import '../services/notification_service.dart';

class DualStreamMonitoringScreen extends StatefulWidget {
  const DualStreamMonitoringScreen({super.key});

  @override
  State<DualStreamMonitoringScreen> createState() =>
      _DualStreamMonitoringScreenState();
}

class _DualStreamMonitoringScreenState
    extends State<DualStreamMonitoringScreen> {
  bool _showOverheadView = true;
  VideoPlayerController? _rpiVideoController;
  final NetworkCameraService _networkCameraService = NetworkCameraService();
  Timer? _detectionTimer;
  bool _isAutoDetecting = false;
  bool _isCapturing = false;
  String _detectionStatus = 'Monitoring...';
  
  @override
  void initState() {
    super.initState();
    _initializeRPiCamera();
    _startAutoDetection();
  }
  
  void _startAutoDetection() {
    // Simulate disease detection every 10 seconds
    _detectionTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_isAutoDetecting && mounted) {
        _performDiseaseDetection();
      }
    });
  }
  
  Future<void> _performDiseaseDetection() async {
    // Simulate AI disease detection
    final random = Random();
    final diseases = ['Healthy', 'White Spot Disease', 'Columnaris', 'Ich'];
    final statuses = ['healthy', 'disease', 'suspicious', 'disease'];
    final confidences = [0.95, 0.87, 0.72, 0.91];
    
    final index = random.nextInt(diseases.length);
    final detectedDisease = diseases[index];
    final status = statuses[index];
    final confidence = confidences[index];
    
    setState(() {
      _detectionStatus = 'Detected: $detectedDisease (${(confidence * 100).toStringAsFixed(1)}%)';
    });
    
    // Auto-capture if disease detected
    if (status == 'disease' || status == 'suspicious') {
      await _captureAndSave(detectedDisease, confidence, status, isAutomatic: true);
    }
  }
  
  Future<void> _initializeRPiCamera() async {
    try {
      _rpiVideoController = await _networkCameraService.initializeVideoStream();
      if (_rpiVideoController != null) {
        setState(() {});
        _rpiVideoController!.play();
      }
    } catch (e) {
      print('RPi camera initialization failed: $e');
    }
  }
  
  Future<void> _captureAndSave(String diseaseName, double confidence, String status, {bool isAutomatic = false}) async {
    if (_isCapturing) return;
    
    setState(() {
      _isCapturing = true;
    });
    
    try {
      // Capture image from RPi camera
      final imagePath = await _networkCameraService.captureImage();
      
      if (imagePath != null) {
        // Create detection data
        final detection = DetectionData(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          diseaseName: diseaseName,
          confidence: confidence,
          timestamp: DateTime.now(),
          imagePath: imagePath,
          status: status,
          severity: status == 'disease' ? 'critical' : 'early',
          cameraView: _showOverheadView ? 'overhead' : 'underwater',
          recommendedAction: status == 'disease' 
              ? 'Isolate affected fish immediately and consult veterinarian'
              : 'Monitor closely for changes',
        );
        
        // Save to database
        final provider = Provider.of<DetectionProvider>(context, listen: false);
        await provider.addDetection(detection);
        
        // Show notification to farmer
        if (status == 'disease' || status == 'suspicious') {
          NotificationService().showCriticalAlert(
            context,
            title: isAutomatic ? '🚨 AUTO-DETECTED: $diseaseName' : '📸 Disease Captured',
            message: '${(confidence * 100).toStringAsFixed(1)}% confidence. Image saved to gallery.',
            severity: status,
          );
        }
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    isAutomatic ? Icons.auto_awesome : Icons.camera_alt,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isAutomatic 
                          ? 'Auto-captured: $diseaseName'
                          : 'Image captured and saved',
                    ),
                  ),
                ],
              ),
              backgroundColor: status == 'disease' ? Colors.red : Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('Error capturing image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to capture image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isCapturing = false;
      });
    }
  }
  
  Future<void> _manualCapture() async {
    await _captureAndSave(
      'Manual Capture',
      1.0,
      'healthy',
      isAutomatic: false,
    );
  }
  
  @override
  void dispose() {
    _detectionTimer?.cancel();
    _rpiVideoController?.dispose();
    _networkCameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dual-Stream Monitoring'),
        backgroundColor: isDarkMode 
            ? const Color(0xFF1A237E)
            : const Color(0xFF0277BD),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // RPi Settings
          Tooltip(
            message: 'RPi Camera Settings',
            child: IconButton(
              onPressed: _showRPiSettings,
              icon: const Icon(Icons.settings),
            ),
          ),
          Consumer<DetectionProvider>(
            builder: (context, provider, _) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Tooltip(
                  message: provider.nightModeEnabled
                      ? 'Night Mode: ON'
                      : 'Night Mode: OFF',
                  child: IconButton(
                    icon: Icon(
                      provider.nightModeEnabled
                          ? Icons.nightlight
                          : Icons.light_mode,
                      color: provider.nightModeEnabled
                          ? Colors.amber
                          : Colors.grey,
                    ),
                    onPressed: () {
                      provider.toggleNightMode();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'IR LED ${provider.nightModeEnabled ? 'ON' : 'OFF'}',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [
                    const Color(0xFF001F3F),
                    const Color(0xFF003366),
                    const Color(0xFF004080),
                  ]
                : [
                    const Color(0xFFF0F9FF),
                    const Color(0xFFE1F5FE),
                  ],
          ),
        ),
        child: Consumer<DetectionProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Dual Stream Views
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Overhead View
                      _buildCameraView(
                        title: 'Overhead View',
                        subtitle: 'Checking for Columnaris & swimming behavior',
                        icon: Icons.videocam,
                        isActive: _showOverheadView,
                        onTap: () {
                          setState(() => _showOverheadView = true);
                        },
                      ),
                      const SizedBox(height: 16),
                      // Underwater (NoIR) View
                      _buildCameraView(
                        title: 'Underwater (NoIR) View',
                        subtitle: 'Detecting Fin Rot & White Spot Disease',
                        icon: Icons.water,
                        isActive: !_showOverheadView,
                        onTap: () {
                          setState(() => _showOverheadView = false);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Control Panel
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF283593) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Detection Status
                        Row(
                          children: [
                            Icon(
                              _isAutoDetecting ? Icons.auto_awesome : Icons.pause_circle,
                              color: _isAutoDetecting ? Colors.green : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _detectionStatus,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isDarkMode ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Auto Detection Toggle
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Auto Disease Detection',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isDarkMode ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                            Switch(
                              value: _isAutoDetecting,
                              onChanged: (value) {
                                setState(() {
                                  _isAutoDetecting = value;
                                  _detectionStatus = value ? 'Auto-detection enabled' : 'Auto-detection paused';
                                });
                              },
                              activeColor: Colors.green,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Manual Capture Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isCapturing ? null : _manualCapture,
                            icon: _isCapturing 
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.camera_alt),
                            label: Text(_isCapturing ? 'Capturing...' : 'Manual Capture'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0277BD),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                // Latest Detection
                _buildLatestDetection(provider),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
        ),
      ),
    );
  }

  Widget _buildCameraView({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? Colors.blue : Colors.grey[300]!,
            width: isActive ? 2 : 1,
          ),
          color: isActive ? Colors.blue.withOpacity(0.05) : Colors.transparent,
        ),
        child: Column(
          children: [
            // Camera Feed Placeholder
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                color: Colors.grey[800],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 48,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Camera Feed',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Camera Info
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        icon,
                        size: 20,
                        color: isActive ? Colors.blue : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              subtitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'ACTIVE',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
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
      ),
    );
  }

  Widget _buildLatestDetection(DetectionProvider provider) {
    if (provider.detections.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.grey[100],
          ),
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No detections yet',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      );
    }

    final latest = provider.detections.first;
    final statusColor = AppTheme.getHealthStatusColor(latest.status);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: statusColor.withOpacity(0.3)),
          color: statusColor.withOpacity(0.05),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Latest Detection',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    latest.severity.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              latest.diseaseName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Confidence',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '${(latest.confidence * 100).toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Camera View',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      latest.cameraView == 'overhead'
                          ? 'Overhead'
                          : 'Underwater',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Time',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      _formatTime(latest.timestamp),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            if (latest.recommendedAction != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, size: 16, color: statusColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        latest.recommendedAction!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
  
  void _showRPiSettings() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: const RPICameraSettingsDialog(),
        ),
      ),
    );
  }
}

class RPICameraSettingsDialog extends StatefulWidget {
  const RPICameraSettingsDialog({super.key});

  @override
  State<RPICameraSettingsDialog> createState() => _RPICameraSettingsDialogState();
}

class _RPICameraSettingsDialogState extends State<RPICameraSettingsDialog> {
  final _urlController = TextEditingController();
  final NetworkCameraService _cameraService = NetworkCameraService();
  bool _isTesting = false;
  bool _isConnected = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _urlController.text = _cameraService.serverUrl;
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _statusMessage = 'Testing connection...';
    });

    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() {
        _isTesting = false;
        _isConnected = false;
        _statusMessage = 'Please enter a URL';
      });
      return;
    }

    _cameraService.setServerUrl(url);
    final connected = await _cameraService.testConnection();

    setState(() {
      _isTesting = false;
      _isConnected = connected;
      _statusMessage = connected 
          ? 'Connected successfully!' 
          : 'Connection failed. Check IP and port.';
    });
  }

  void _saveSettings() {
    final url = _urlController.text.trim();
    if (url.isNotEmpty) {
      _cameraService.setServerUrl(url);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('RPi camera settings saved'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0277BD).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.router,
                  color: Color(0xFF0277BD),
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RPi Camera Settings',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Configure Raspberry Pi connection',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // URL Input
          TextField(
            controller: _urlController,
            decoration: InputDecoration(
              labelText: 'RPi Server URL',
              hintText: 'http://192.168.1.100:5000',
              prefixIcon: const Icon(Icons.link),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              helperText: 'Enter your Raspberry Pi IP address and port',
            ),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 16),

          // Status Message
          if (_statusMessage.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isConnected 
                    ? Colors.green.withOpacity(0.1)
                    : _isTesting
                        ? Colors.blue.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isConnected 
                      ? Colors.green
                      : _isTesting
                          ? Colors.blue
                          : Colors.red,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isConnected 
                        ? Icons.check_circle
                        : _isTesting
                            ? Icons.info
                            : Icons.error,
                    color: _isConnected 
                        ? Colors.green
                        : _isTesting
                            ? Colors.blue
                            : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _statusMessage,
                      style: TextStyle(
                        color: _isConnected 
                            ? Colors.green[700]
                            : _isTesting
                                ? Colors.blue[700]
                                : Colors.red[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),

          // Example URLs
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      'Example URLs:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildExampleUrl('http://192.168.1.100:5000'),
                _buildExampleUrl('http://192.168.0.50:5000'),
                _buildExampleUrl('http://10.0.0.5:5000'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isTesting ? null : _testConnection,
                  icon: _isTesting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.wifi_find),
                  label: Text(_isTesting ? 'Testing...' : 'Test Connection'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _urlController.text.trim().isEmpty ? null : _saveSettings,
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0277BD),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExampleUrl(String url) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _urlController.text = url;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(Icons.touch_app, size: 14, color: Colors.grey[500]),
            const SizedBox(width: 6),
            Text(
              url,
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue[700],
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
