import 'package:flutter/material.dart';
import '../services/network_camera_service.dart';
import '../widgets/mjpeg_stream_viewer.dart';

class RPiCameraConfigScreen extends StatefulWidget {
  const RPiCameraConfigScreen({super.key});

  @override
  State<RPiCameraConfigScreen> createState() => _RPiCameraConfigScreenState();
}

class _RPiCameraConfigScreenState extends State<RPiCameraConfigScreen> {
  final _ipController = TextEditingController(text: '192.168.1.100');
  final _portController = TextEditingController(text: '5000');
  final NetworkCameraService _cameraService = NetworkCameraService();
  bool _showStream = false;
  String? _streamUrl;

  @override
  void initState() {
    super.initState();
    // Load saved URL if any
    _streamUrl = _cameraService.getVideoFeed1Url();
  }

  void _updateStreamUrl() {
    final ip = _ipController.text.trim();
    final port = _portController.text.trim();
    final url = 'http://$ip:$port';
    
    _cameraService.setServerUrl(url);
    
    setState(() {
      _streamUrl = _cameraService.getVideoFeed1Url();
      _showStream = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('RPi Camera Setup'),
        backgroundColor: isDarkMode 
            ? const Color(0xFF1A237E)
            : const Color(0xFF0277BD),
        foregroundColor: Colors.white,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Instructions Card
              Card(
                color: isDarkMode ? const Color(0xFF2D3748) : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Setup Instructions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '1. Find your Raspberry Pi IP address:\n   Run "hostname -I" on your RPi\n\n'
                        '2. Make sure your RPi server is running\n\n'
                        '3. Enter the IP address and port below\n\n'
                        '4. Tap "Connect to Camera"',
                        style: TextStyle(
                          color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Configuration Card
              Card(
                color: isDarkMode ? const Color(0xFF2D3748) : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Raspberry Pi Configuration',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // IP Address Field
                      TextField(
                        controller: _ipController,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          labelText: 'IP Address',
                          hintText: '192.168.1.100',
                          labelStyle: TextStyle(
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                          prefixIcon: const Icon(Icons.computer),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: isDarkMode ? const Color(0xFF1A202C) : Colors.grey[100],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Port Field
                      TextField(
                        controller: _portController,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Port',
                          hintText: '5000',
                          labelStyle: TextStyle(
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                          prefixIcon: const Icon(Icons.settings_ethernet),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: isDarkMode ? const Color(0xFF1A202C) : Colors.grey[100],
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),
                      
                      // Connect Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _updateStreamUrl,
                          icon: const Icon(Icons.videocam),
                          label: const Text('Connect to Camera'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: const Color(0xFF0277BD),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      
                      if (_streamUrl != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.link, color: Colors.blue, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _streamUrl!,
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              // Camera Stream Preview
              if (_showStream && _streamUrl != null) ...[
                const SizedBox(height: 20),
                Card(
                  color: isDarkMode ? const Color(0xFF2D3748) : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Camera 1 - Live Stream',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: MjpegStreamViewer(
                              streamUrl: _streamUrl!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }
}
