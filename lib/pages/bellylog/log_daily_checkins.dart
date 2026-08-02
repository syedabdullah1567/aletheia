import 'package:aletheia/utilities/uniform_appbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/bellylog_database.dart';
import '../../utilities/custom_date_time.dart';

class LogDailyCheckin extends StatefulWidget {
  const LogDailyCheckin({super.key});

  @override
  State<LogDailyCheckin> createState() => _LogDailyCheckinState();
}

class _LogDailyCheckinState extends State<LogDailyCheckin> {
  final BellyLogDatabase db = BellyLogDatabase();

  late DateTime _currentTime;

  String _selectedStressLevel = '';
  // Replaced the string state with a text controller for the sleep input
  final TextEditingController _sleepController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    db.loadData();
  }

  @override
  void dispose() {
    _sleepController.dispose();
    super.dispose();
  }

  void _saveDailyCheckin() {
    // 1. Validate Stress Level
    if (_selectedStressLevel == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a stress level (1-5).')),
      );
      return;
    }

    // 2. Validate Sleep Hours (Must not be empty and must be a valid number)
    final sleepText = _sleepController.text.trim();
    if (sleepText.isEmpty || double.tryParse(sleepText) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid number for hours slept.'),
        ),
      );
      return;
    }

    String timestampKey = DateFormat(
      'yyyy-MM-dd HH:mm:ss',
    ).format(_currentTime);

    // Save data (converting sleep text to a double safely)
    db.dailyCheckins[timestampKey] = {
      'stress': _selectedStressLevel,
      'sleep': double.parse(sleepText),
    };

    db.updateDataBase();

    // Confirm and pop page back to home
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged daily check-in successfully!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: UniformAppbar(
        leadIcon: Icon(Icons.arrow_back_rounded),
        titleText: "Daily Check-in",
        onPress: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Auto Collected Time Banner
            TimePickerBanner(
              currentTime: _currentTime,
              onTimeChanged: (newTime) {
                setState(() {
                  _currentTime = newTime;
                });
              },
            ),

            const SizedBox(height: 32),

            // Stress Level Title
            Text(
              'What were your overall stress levels today?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),

            Center(
              child: Wrap(
                spacing: 8.0,
                children: ['1', '2', '3', '4', '5'].map((type) {
                  final isSelected = _selectedStressLevel == type;
                  return ChoiceChip(
                    label: Text(type),
                    selected: isSelected,
                    selectedColor: colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    onSelected: (bool selected) {
                      if (selected) {
                        setState(() {
                          _selectedStressLevel = type;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 32),

            // Sleep Title
            Text(
              'How many hours did you sleep tonight?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),

            // Sleep Text Field
            TextField(
              controller: _sleepController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                hintText: 'e.g., 7.5',
                filled: true,
                fillColor: colorScheme.onSurface.withValues(alpha: 0.08),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
                suffixText: 'hours',
              ),
            ),

            const SizedBox(height: 40),

            // Save Action Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _saveDailyCheckin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.save_rounded),
                label: const Text(
                  'Save Daily Check-in',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
