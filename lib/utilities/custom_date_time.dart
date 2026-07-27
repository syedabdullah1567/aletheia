import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimePickerBanner extends StatelessWidget {
  final DateTime currentTime;
  final ValueChanged<DateTime> onTimeChanged;

  const DateTimePickerBanner({
    super.key,
    required this.currentTime,
    required this.onTimeChanged,
  });

  Future<void> _pickDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: currentTime,
      firstDate: currentTime,
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(currentTime),
      );

      if (pickedTime != null) {
        final newDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        onTimeChanged(newDateTime);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _PickerCard(
      icon: Icons.calendar_month_rounded,
      label: 'Due date',
      value: DateFormat('MMMM d, yyyy • h:mm a').format(currentTime),
      onTap: () => _pickDateTime(context),
    );
  }
}

class TimePickerBanner extends StatelessWidget {
  final DateTime currentTime;
  final ValueChanged<DateTime> onTimeChanged;

  const TimePickerBanner({
    super.key,
    required this.currentTime,
    required this.onTimeChanged,
  });

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentTime),
    );

    if (pickedTime != null) {
      final newDateTime = DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      onTimeChanged(newDateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _PickerCard(
      icon: Icons.schedule_rounded,
      label: 'Due time',
      value: TimeOfDay.fromDateTime(currentTime).format(context),
      onTap: () => _pickTime(context),
    );
  }
}

class _PickerCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _PickerCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(20),

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),

        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,

                decoration: BoxDecoration(
                  color: colorScheme.onSecondaryContainer.withValues(
                    alpha: 0.08,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),

                child: Icon(icon, color: colorScheme.onSecondaryContainer),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSecondaryContainer.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      value,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSecondaryContainer.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
