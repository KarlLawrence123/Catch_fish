import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/detection_data.dart';
import '../theme/app_theme.dart';

class HealthLogsScreen extends StatefulWidget {
  const HealthLogsScreen({super.key});

  @override
  State<HealthLogsScreen> createState() => _HealthLogsScreenState();
}

class _HealthLogsScreenState extends State<HealthLogsScreen> {
  late DateTime _selectedDate;
  late DateTime _focusedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _focusedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Logs'),
        backgroundColor: isDarkMode 
            ? const Color(0xFF1A237E)
            : const Color(0xFF0277BD),
        foregroundColor: Colors.white,
        elevation: 0,
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
                // Calendar View
                _buildCalendarView(provider),
                const SizedBox(height: 24),
                // Detections for Selected Date
                _buildDetectionsForDate(provider),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
        ),
      ),
    );
  }

  Widget _buildCalendarView(DetectionProvider provider) {
    final detectionsByDate = <DateTime, List<DetectionData>>{};
    for (var detection in provider.detections) {
      final date = DateTime(
        detection.timestamp.year,
        detection.timestamp.month,
        detection.timestamp.day,
      );
      detectionsByDate.putIfAbsent(date, () => []).add(detection);
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
          color: Colors.white,
        ),
        child: Column(
          children: [
            // Month/Year Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      setState(() {
                        _focusedDate = DateTime(
                          _focusedDate.year,
                          _focusedDate.month - 1,
                        );
                      });
                    },
                  ),
                  Text(
                    '${_getMonthName(_focusedDate.month)} ${_focusedDate.year}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      setState(() {
                        _focusedDate = DateTime(
                          _focusedDate.year,
                          _focusedDate.month + 1,
                        );
                      });
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 0),
            // Weekday Headers
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                    .map((day) => SizedBox(
                          width: 40,
                          child: Center(
                            child: Text(
                              day,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
            const Divider(height: 0),
            // Calendar Grid
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildCalendarGrid(detectionsByDate),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(Map<DateTime, List<DetectionData>> detectionsByDate) {
    final firstDay = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final lastDay = DateTime(_focusedDate.year, _focusedDate.month + 1, 0);
    final daysInMonth = lastDay.day;
    final startingWeekday = firstDay.weekday % 7;

    final days = <Widget>[];

    // Empty cells for days before month starts
    for (int i = 0; i < startingWeekday; i++) {
      days.add(const SizedBox(width: 40, height: 40));
    }

    // Days of the month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_focusedDate.year, _focusedDate.month, day);
      final hasDetections = detectionsByDate.containsKey(date);
      final isSelected = _selectedDate.year == date.year &&
          _selectedDate.month == date.month &&
          _selectedDate.day == date.day;
      final isToday = DateTime.now().year == date.year &&
          DateTime.now().month == date.month &&
          DateTime.now().day == date.day;

      days.add(
        GestureDetector(
          onTap: () {
            setState(() => _selectedDate = date);
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? Colors.blue
                  : isToday
                      ? Colors.blue.withOpacity(0.2)
                      : Colors.transparent,
              border: isToday && !isSelected
                  ? Border.all(color: Colors.blue, width: 2)
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (hasDetections)
                  Positioned(
                    bottom: 2,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? Colors.white : Colors.red,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1,
      children: days,
    );
  }

  Widget _buildDetectionsForDate(DetectionProvider provider) {
    final detectionsForDate = provider.detections.where((detection) {
      final detectionDate = DateTime(
        detection.timestamp.year,
        detection.timestamp.month,
        detection.timestamp.day,
      );
      final selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      );
      return detectionDate == selectedDate;
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detections for ${_formatDate(_selectedDate)}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          if (detectionsForDate.isEmpty)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[100],
              ),
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No detections on this date',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: detectionsForDate.length,
              itemBuilder: (context, index) {
                final detection = detectionsForDate[index];
                final statusColor =
                    AppTheme.getHealthStatusColor(detection.status);
                return _buildDetectionCard(detection, statusColor);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDetectionCard(DetectionData detection, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
        color: statusColor.withOpacity(0.05),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  detection.diseaseName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  detection.severity.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Confidence: ${(detection.confidence * 100).toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                detection.cameraView == 'overhead' ? 'Overhead' : 'Underwater',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _formatDetailedTime(detection.timestamp),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  String _formatDate(DateTime date) {
    return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
  }

  String _formatDetailedTime(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
