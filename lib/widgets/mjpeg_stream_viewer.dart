import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

/// Widget to display MJPEG stream from Raspberry Pi camera
class MjpegStreamViewer extends StatefulWidget {
  final String streamUrl;
  final BoxFit fit;
  final double? width;
  final double? height;

  const MjpegStreamViewer({
    super.key,
    required this.streamUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  State<MjpegStreamViewer> createState() => _MjpegStreamViewerState();
}

class _MjpegStreamViewerState extends State<MjpegStreamViewer> {
  Uint8List? _currentFrame;
  bool _isLoading = true;
  String? _errorMessage;
  http.Client? _httpClient;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _startStream();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _httpClient?.close();
    super.dispose();
  }

  Future<void> _startStream() async {
    try {
      _httpClient = http.Client();
      final request = http.Request('GET', Uri.parse(widget.streamUrl));
      final response = await _httpClient!.send(request);

      if (response.statusCode == 200) {
        List<int> buffer = [];
        bool inFrame = false;

        await for (var chunk in response.stream) {
          if (_isDisposed) break;

          buffer.addAll(chunk);

          // Look for JPEG start marker (0xFF, 0xD8)
          for (int i = 0; i < buffer.length - 1; i++) {
            if (buffer[i] == 0xFF && buffer[i + 1] == 0xD8) {
              inFrame = true;
              buffer = buffer.sublist(i);
              break;
            }
          }

          // Look for JPEG end marker (0xFF, 0xD9)
          if (inFrame) {
            for (int i = 0; i < buffer.length - 1; i++) {
              if (buffer[i] == 0xFF && buffer[i + 1] == 0xD9) {
                // Found complete frame
                final frame = Uint8List.fromList(buffer.sublist(0, i + 2));
                if (mounted && !_isDisposed) {
                  setState(() {
                    _currentFrame = frame;
                    _isLoading = false;
                    _errorMessage = null;
                  });
                }
                buffer = buffer.sublist(i + 2);
                inFrame = false;
                break;
              }
            }
          }

          // Prevent buffer from growing too large
          if (buffer.length > 1024 * 1024) {
            buffer.clear();
            inFrame = false;
          }
        }
      } else {
        if (mounted && !_isDisposed) {
          setState(() {
            _errorMessage = 'Stream error: ${response.statusCode}';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted && !_isDisposed) {
        setState(() {
          _errorMessage = 'Connection failed: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _startStream();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_currentFrame == null) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.black,
      );
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Image.memory(
        _currentFrame!,
        fit: widget.fit,
        gaplessPlayback: true,
      ),
    );
  }
}
