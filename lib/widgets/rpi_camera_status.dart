import 'package:flutter/material.dart';
import '../services/network_camera_service.dart';

class RPICameraStatus extends StatefulWidget {
  const RPICameraStatus({super.key});

  @override
  State<RPICameraStatus> createState() => _RPICameraStatusState();
}

class _RPICameraStatusState extends State<RPICameraStatus> {
  final NetworkCameraService _cameraService = NetworkCameraService();
  Map<String, dynamic> _status = {
    'connected': false,
    'camera_active': false,
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    setState(() {
      _isLoading = true;
    });
    
    final status = await _cameraService.getCameraStatus();
    
    setState(() {
      _status = status;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text('Checking RPi...'),
          ],
        ),
      );
    }

    final isConnected = _status['connected'] == true;
    final isActive = _status['camera_active'] == true;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isConnected 
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isConnected ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isConnected ? Icons.router : Icons.router_outlined,
            size: 16,
            color: isConnected ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 6),
          Text(
            isConnected ? 'RPi Online' : 'RPi Offline',
            style: TextStyle(
              color: isConnected ? Colors.green : Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (isConnected && isActive) ...[
            const SizedBox(width: 6),
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
