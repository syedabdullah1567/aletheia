import 'package:aletheia/utilities/uniform_appbar.dart';

import '../../utilities/custom_date_time.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this to your pubspec.yaml for easy date formatting
import '../../data/bellylog_database.dart'; // Adjust path if necessary

class LogMeal extends StatefulWidget {
  const LogMeal({super.key});

  @override
  State<LogMeal> createState() => _LogMealState();
}

class _LogMealState extends State<LogMeal> {
  final BellyLogDatabase db = BellyLogDatabase();
  final TextEditingController _foodController = TextEditingController();

  // State variables
  late DateTime _currentTime;
  String _selectedMealType = 'Breakfast'; // Default selection

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    db.loadData(); // Pull existing history from Hive
  }

  @override
  void dispose() {
    _foodController.dispose();
    super.dispose();
  }

  void _saveMeal() {
    if (_foodController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter what you ate!')),
      );
      return;
    }

    // Generate unique key timestamp (e.g., "2026-07-03 20:30:00")
    String timestampKey = DateFormat(
      'yyyy-MM-dd HH:mm:ss',
    ).format(_currentTime);

    // Save inside our local Map
    db.mealLog[timestampKey] = {
      'type': _selectedMealType,
      'items': _foodController.text.trim(),
    };

    // Commit changes to Hive database
    db.updateDataBase();

    // Confirm and pop page back to home
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logged $_selectedMealType successfully!')),
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
        titleText: "Log Meal",
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

            // Selector Title
            Text(
              'Which meal is this?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),

            // Meal Type Segment Chips
            Wrap(
              spacing: 8.0,
              children: ['Breakfast', 'Lunch', 'Dinner', 'Snack'].map((type) {
                final isSelected = _selectedMealType == type;
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
                        _selectedMealType = type;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Content Text Field
            Text(
              'What did you have?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _foodController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g., Pizza, Salad, Apple Juice...',
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
                onPressed: _saveMeal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.save_rounded),
                label: const Text(
                  'Save Meal Data',
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
