import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../models/detection_data.dart';
import '../theme/app_theme.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  String _filterStatus = 'all';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Gallery'),
        backgroundColor: isDark 
            ? const Color(0xFF1A237E)
            : const Color(0xFF0277BD),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filterStatus = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Images')),
              const PopupMenuItem(value: 'healthy', child: Text('Healthy')),
              const PopupMenuItem(value: 'suspicious', child: Text('Suspicious')),
              const PopupMenuItem(value: 'disease', child: Text('Disease Detected')),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
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
            // Filter detections based on selected filter
            List<DetectionData> filteredDetections = provider.detections;
            
            if (_filterStatus != 'all') {
              filteredDetections = provider.detections
                  .where((d) => d.status.toLowerCase() == _filterStatus)
                  .toList();
            }

            if (filteredDetections.isEmpty) {
              return _buildEmptyState(isDark);
            }

            return Column(
              children: [
                // Stats Header
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        'Total',
                        provider.detections.length.toString(),
                        Colors.blue,
                        isDark,
                      ),
                      _buildStatCard(
                        'Healthy',
                        provider.detections
                            .where((d) => d.status == 'healthy')
                            .length
                            .toString(),
                        Colors.green,
                        isDark,
                      ),
                      _buildStatCard(
                        'Disease',
                        provider.detections
                            .where((d) => d.status == 'disease')
                            .length
                            .toString(),
                        Colors.red,
                        isDark,
                      ),
                    ],
                  ),
                ),

                // Gallery Grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: filteredDetections.length,
                    itemBuilder: (context, index) {
                      final detection = filteredDetections[index];
                      return _buildImageCard(detection, isDark);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF283593) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard(DetectionData detection, bool isDark) {
    final statusColor = AppTheme.getHealthStatusColor(detection.status);
    
    return GestureDetector(
      onTap: () => _showImageDetail(detection),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF283593) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: detection.imagePath != null && File(detection.imagePath!).existsSync()
                    ? Image.file(
                        File(detection.imagePath!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : Container(
                        color: isDark ? const Color(0xFF1A237E) : Colors.grey[200],
                        child: Icon(
                          Icons.image_not_supported,
                          size: 48,
                          color: isDark ? Colors.white30 : Colors.grey[400],
                        ),
                      ),
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          detection.diseaseName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF0D47A1),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(detection.confidence * 100).toStringAsFixed(1)}% confidence',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(detection.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.white60 : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 80,
            color: isDark ? Colors.white30 : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Images Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Captured images from RPi camera\nwill appear here',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white60 : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showImageDetail(DetectionData detection) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF283593) : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: detection.imagePath != null && File(detection.imagePath!).existsSync()
                    ? Image.file(
                        File(detection.imagePath!),
                        fit: BoxFit.contain,
                        height: 300,
                      )
                    : Container(
                        height: 300,
                        color: isDark ? const Color(0xFF1A237E) : Colors.grey[200],
                        child: const Icon(Icons.image_not_supported, size: 64),
                      ),
              ),

              // Details
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detection.diseaseName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0D47A1),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow('Confidence', '${(detection.confidence * 100).toStringAsFixed(1)}%', isDark),
                    _buildDetailRow('Status', detection.status.toUpperCase(), isDark),
                    _buildDetailRow('Date', _formatDate(detection.timestamp), isDark),
                    if (detection.cameraView != null)
                      _buildDetailRow('Camera', detection.cameraView!, isDark),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : const Color(0xFF0D47A1),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
