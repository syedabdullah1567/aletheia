import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/bellylog_database.dart';
import '../../utilities/custom_date_time.dart';

class LogBowelMovement extends StatefulWidget {
  const LogBowelMovement({super.key});

  @override
  State<LogBowelMovement> createState() => _LogBowelMovementState();
}

class _LogBowelMovementState extends State<LogBowelMovement> {
  final BellyLogDatabase db = BellyLogDatabase();

  // State variables
  late DateTime _currentTime;

  String _selectedStoolType = '';
  String _urgency = '';

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    db.loadData(); // Pull existing history from Hive
  }

  void _saveBowelMovement() {
    if (_selectedStoolType == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a stool type!')),
      );
      return;
    }

    if (_urgency == '') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please choose urgency!')));
      return;
    }

    // Generate unique key timestamp (e.g., "2026-07-03 20:30:00")
    String timestampKey = DateFormat(
      'yyyy-MM-dd HH:mm:ss',
    ).format(_currentTime);

    // FIXED: Changed db.bowelLog to db.bowelMovements to match your database.dart file
    db.bowelLog[timestampKey] = {
      'type': _selectedStoolType,
      'urgency': _urgency,
    };

    // Commit changes to Hive database
    db.updateDataBase();

    // Confirm and pop page back to home
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged bowel movement successfully!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Log Bowel Movement',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // UPDATED: Time Banner is now wrapped in a GestureDetector
            TimePickerBanner(
              currentTime: _currentTime,
              onTimeChanged: (newTime) {
                setState(() {
                  _currentTime = newTime;
                });
              },
            ),

            const SizedBox(height: 32),

            Center(
              child: Image.asset(
                'assets/bristol_stool_chart.jpg',
                width: 300,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 32),

            // Selector Title
            Text(
              'Identify the stool type',
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
                children: ['1', '2', '3', '4', '5', '6', '7'].map((type) {
                  final isSelected = _selectedStoolType == type;
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
                          _selectedStoolType = type;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 32),

            // Selector Title
            Text(
              'Was it urgent?',
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
                children: ['YES', 'NO'].map((type) {
                  final isSelected = _urgency == type;
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
                          _urgency = type;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 40),

            // Save Action Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _saveBowelMovement,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.save_rounded),
                label: const Text(
                  'Save Bowel Movement Data',
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
