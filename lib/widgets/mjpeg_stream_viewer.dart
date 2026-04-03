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
        int frameCount = 0;

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
                frameCount++;

                // Skip every other frame for lower latency (show 15fps instead of 30fps)
                // This reduces processing overhead and improves responsiveness
                if (frameCount % 2 == 0) {
                  final frame = Uint8List.fromList(buffer.sublist(0, i + 2));
                  if (mounted && !_isDisposed) {
                    setState(() {
                      _currentFrame = frame;
                      _isLoading = false;
                      _errorMessage = null;
                    });
                  }
                }

                buffer = buffer.sublist(i + 2);
                inFrame = false;
                break;
              }
            }
          }

          // Prevent buffer from growing too large - reduced from 1MB to 512KB for faster processing
          if (buffer.length > 512 * 1024) {
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 40),
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _errorMessage = null;
                    });
                    _startStream();
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Retry', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
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
