import 'package:aletheia/utilities/uniform_appbar.dart';

import '../../utilities/custom_date_time.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/bellylog_database.dart';

class LogSymptom extends StatefulWidget {
  const LogSymptom({super.key});

  @override
  State<LogSymptom> createState() => _LogSymptomState();
}

class _LogSymptomState extends State<LogSymptom> {
  final BellyLogDatabase db = BellyLogDatabase();

  // Renamed the controller to clarify its new purpose
  final TextEditingController _otherSymptomController = TextEditingController();

  late DateTime _currentTime;

  // 1. Define standard symptoms for the choices
  final List<String> _commonSymptoms = [
    'Bloating',
    'Cramping',
    'Diarrhea',
    'Constipation',
    'Nausea',
    'Gas',
    'Heartburn',
    'Acid Reflux',
  ];

  // 2. State list to hold all currently selected chips
  final List<String> _selectedSymptoms = [];

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    db.loadData(); // Pull existing history from Hive
  }

  @override
  void dispose() {
    _otherSymptomController.dispose();
    super.dispose();
  }

  void _saveSymptom() {
    final otherSymptomText = _otherSymptomController.text.trim();

    // 3. Validation: Make sure they selected a chip OR typed an 'other' symptom
    if (_selectedSymptoms.isEmpty && otherSymptomText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or enter at least one symptom!'),
        ),
      );
      return;
    }

    String timestampKey = DateFormat(
      'yyyy-MM-dd HH:mm:ss',
    ).format(_currentTime);

    // 4. Save as a structured Map in the database
    // Note: Ensure your database.dart uses 'symptomLog' or 'symptoms' consistently!
    db.symptomLog[timestampKey] = {
      'selected_symptoms': _selectedSymptoms,
      'other_symptoms': otherSymptomText,
    };

    db.updateDataBase();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged symptoms successfully!')),
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
        titleText: "Log Symptom",
        onPress: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TimePickerBanner(
              currentTime: _currentTime,
              onTimeChanged: (newTime) {
                setState(() {
                  _currentTime = newTime;
                });
              },
            ),

            const SizedBox(height: 32),

            // Multi-Select Title
            Text(
              'What symptoms are you experiencing?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),

            // Multi-Select Chips (FilterChips)
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _commonSymptoms.map((symptom) {
                final isSelected = _selectedSymptoms.contains(symptom);
                return FilterChip(
                  label: Text(symptom),
                  selected: isSelected,
                  selectedColor: colorScheme.primary,
                  checkmarkColor: isSelected ? colorScheme.onPrimary : null,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _selectedSymptoms.add(symptom);
                      } else {
                        _selectedSymptoms.remove(symptom);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Optional Text Field Title
            Text(
              'Other symptoms (optional)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),

            // Content Text Field
            TextField(
              controller: _otherSymptomController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g., Headache, Back pain, Fever...',
                filled: true,
                fillColor: colorScheme.onSurface.withValues(alpha: 0.08),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 40),

            // Save Action Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _saveSymptom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.save_rounded),
                label: const Text(
                  'Save Symptom Data',
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
