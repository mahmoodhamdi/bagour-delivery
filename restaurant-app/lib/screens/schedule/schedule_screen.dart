import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../providers/restaurant_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/custom_button.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  final Map<String, Map<String, dynamic>> _schedule = {
    'saturday': {'isOpen': true, 'openTime': '09:00', 'closeTime': '23:00'},
    'sunday': {'isOpen': true, 'openTime': '09:00', 'closeTime': '23:00'},
    'monday': {'isOpen': true, 'openTime': '09:00', 'closeTime': '23:00'},
    'tuesday': {'isOpen': true, 'openTime': '09:00', 'closeTime': '23:00'},
    'wednesday': {'isOpen': true, 'openTime': '09:00', 'closeTime': '23:00'},
    'thursday': {'isOpen': true, 'openTime': '09:00', 'closeTime': '23:00'},
    'friday': {'isOpen': false, 'openTime': '09:00', 'closeTime': '23:00'},
  };

  final Map<String, String> _dayNames = {
    'saturday': 'السبت',
    'sunday': 'الأحد',
    'monday': 'الإثنين',
    'tuesday': 'الثلاثاء',
    'wednesday': 'الأربعاء',
    'thursday': 'الخميس',
    'friday': 'الجمعة',
  };

  bool _isLoading = false;

  Future<void> _selectTime(String day, bool isOpenTime) async {
    final currentTime = _schedule[day]![isOpenTime ? 'openTime' : 'closeTime'] as String;
    final parts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      setState(() {
        _schedule[day]![isOpenTime ? 'openTime' : 'closeTime'] =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _saveSchedule() async {
    setState(() => _isLoading = true);

    try {
      await ref.read(restaurantProvider.notifier).updateSchedule(_schedule);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ مواعيد العمل بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل حفظ مواعيد العمل: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مواعيد العمل'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ..._schedule.entries.map((entry) => _buildDayCard(entry.key)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomButton(
              onPressed: _saveSchedule,
              text: 'حفظ التغييرات',
              isLoading: _isLoading,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(String day) {
    final dayData = _schedule[day]!;
    final isOpen = dayData['isOpen'] as bool;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  _dayNames[day]!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: isOpen,
                  activeThumbColor: AppTheme.primaryColor,
                  onChanged: (value) {
                    setState(() {
                      _schedule[day]!['isOpen'] = value;
                    });
                  },
                ),
              ],
            ),
            if (isOpen) ...[
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: _buildTimeSelector(
                      label: 'من',
                      time: dayData['openTime'] as String,
                      onTap: () => _selectTime(day, true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTimeSelector(
                      label: 'إلى',
                      time: dayData['closeTime'] as String,
                      onTap: () => _selectTime(day, false),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector({
    required String label,
    required String time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(label, style: TextStyle(color: Colors.grey[600])),
            const Spacer(),
            Text(
              time,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.access_time, size: 20),
          ],
        ),
      ),
    );
  }
}
