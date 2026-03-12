import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/detection_data.dart';
import '../theme/app_theme.dart';
import '../widgets/detection_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'all';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Detection History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _showDateRangeDialog,
          ),
        ],
      ),
      body: Consumer<DetectionProvider>(
        builder: (context, provider, child) {
          final filteredDetections = _getFilteredDetections(provider.detections);

          return Column(
            children: [
              // Filter Summary
              if (_selectedFilter != 'all' || _startDate != null || _endDate != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_list,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getFilterSummary(),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearFilters,
                        color: AppTheme.primaryColor,
                        iconSize: 20,
                      ),
                    ],
                  ),
                ),

              // Statistics Cards
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Total Detections',
                        filteredDetections.length.toString(),
                        Icons.analytics,
                        AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Disease Cases',
                        filteredDetections.where((d) => d.status == 'disease').length.toString(),
                        Icons.sick,
                        AppTheme.dangerColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Detection List
              Expanded(
                child: filteredDetections.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No detections found',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your filters',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredDetections.length,
                        itemBuilder: (context, index) {
                          final detection = filteredDetections[index];
                          return DetectionCard(
                            detection: detection,
                            onTap: () {
                              _showDetectionDetails(context, detection);
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isDark ? Colors.white : const Color(0xFF0D47A1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DetectionData> _getFilteredDetections(List<DetectionData> detections) {
    var filtered = List<DetectionData>.from(detections);

    // Filter by status/disease type
    if (_selectedFilter != 'all') {
      if (_selectedFilter == 'healthy') {
        filtered = filtered.where((d) => d.status == 'healthy').toList();
      } else if (_selectedFilter == 'suspicious') {
        filtered = filtered.where((d) => d.status == 'suspicious').toList();
      } else if (_selectedFilter == 'disease') {
        filtered = filtered.where((d) => d.status == 'disease').toList();
      } else {
        // Filter by specific disease name
        filtered = filtered.where((d) => d.diseaseName.toLowerCase() == _selectedFilter.toLowerCase()).toList();
      }
    }

    // Filter by date range
    if (_startDate != null) {
      filtered = filtered.where((d) => d.timestamp.isAfter(_startDate!)).toList();
    }
    if (_endDate != null) {
      final endOfDay = DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
      filtered = filtered.where((d) => d.timestamp.isBefore(endOfDay)).toList();
    }

    return filtered;
  }

  String _getFilterSummary() {
    final parts = <String>[];
    
    if (_selectedFilter != 'all') {
      parts.add('Filter: ${_selectedFilter.toUpperCase()}');
    }
    
    if (_startDate != null && _endDate != null) {
      parts.add('${_formatDate(_startDate!)} - ${_formatDate(_endDate!)}');
    } else if (_startDate != null) {
      parts.add('From ${_formatDate(_startDate!)}');
    } else if (_endDate != null) {
      parts.add('Until ${_formatDate(_endDate!)}');
    }
    
    return parts.join(' • ');
  }

  void _clearFilters() {
    setState(() {
      _selectedFilter = 'all';
      _startDate = null;
      _endDate = null;
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterOption('all', 'All Detections'),
            _buildFilterOption('healthy', 'Healthy'),
            _buildFilterOption('suspicious', 'Suspicious'),
            _buildFilterOption('disease', 'Disease'),
            const Divider(),
            _buildFilterOption('Columnaris', 'Columnaris'),
            _buildFilterOption('Aeromonas', 'Aeromonas'),
            _buildFilterOption('White Spot', 'White Spot'),
            _buildFilterOption('Fungal Infection', 'Fungal Infection'),
            _buildFilterOption('Fin Rot', 'Fin Rot'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String value, String label) {
    return RadioListTile<String>(
      title: Text(label),
      value: value,
      groupValue: _selectedFilter,
      onChanged: (value) {
        setState(() {
          _selectedFilter = value!;
        });
        Navigator.of(context).pop();
      },
    );
  }

  void _showDateRangeDialog() {
    showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    ).then((range) {
      if (range != null) {
        setState(() {
          _startDate = range.start;
          _endDate = range.end;
        });
      }
    });
  }

  void _showDetectionDetails(BuildContext context, DetectionData detection) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.8,
        minChildSize: 0.4,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.getHealthStatusColor(detection.status).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        AppTheme.getHealthStatusEmoji(detection.status),
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            detection.diseaseName,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${(detection.confidence * 100).toStringAsFixed(1)}% confidence',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Status', detection.status),
                      _buildDetailRow('Time Detected', _formatDateTime(detection.timestamp)),
                      _buildDetailRow('Detection ID', detection.id),
                      if (detection.recommendedAction != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Recommended Action',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            detection.recommendedAction!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
