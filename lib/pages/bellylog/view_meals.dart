import 'package:aletheia/utilities/uniform_appbar.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class ViewMealLogs extends StatefulWidget {
  const ViewMealLogs({super.key});

  @override
  State<ViewMealLogs> createState() => _ViewMealLogsState();
}

class _ViewMealLogsState extends State<ViewMealLogs> {
  final Box _myBox = Hive.box('MyBox');
  List<String> sortedKeys = [];
  Map<String, dynamic> mealLog = {};

  @override
  void initState() {
    super.initState();
    loadMealLog();
  }

  void loadMealLog() {
    setState(() {
      // Safely transform Hive's dynamic map into a strongly-typed string map
      final rawData = _myBox.get('MEALLOG');
      if (rawData != null) {
        mealLog = Map<String, dynamic>.from(rawData);
        // Sort keys in descending order so the newest logs appear first
        sortedKeys = mealLog.keys.toList()..sort((a, b) => b.compareTo(a));
      } else {
        mealLog = {};
        sortedKeys = [];
      }
    });
  }

  // Helper helper function to return icons for specific meal types
  IconData _getMealIcon(String type) {
    switch (type.toLowerCase()) {
      case 'breakfast':
        return Icons.wb_twighlight;
      case 'lunch':
        return Icons.wb_sunny;
      case 'dinner':
        return Icons.dark_mode;
      default:
        return Icons.apple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: UniformAppbar(
        leadIcon: Icon(Icons.arrow_back_rounded),
        titleText: "View Meals",
        onPress: () => Navigator.pop(context),
      ),
      body: sortedKeys.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 64,
                    color: colorScheme.outlineVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No meals logged yet!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              itemCount: sortedKeys.length,
              itemBuilder: (context, index) {
                String rawTimestamp = sortedKeys[index];

                // Safely cast the individual entry as a Map
                Map<dynamic, dynamic> entryData = mealLog[rawTimestamp] ?? {};
                String mealType = entryData['type'] ?? 'Meal';
                String foodItems = entryData['items'] ?? '';

                // Format the raw timestamp string nicely
                String formattedTime = '';
                try {
                  DateTime parsedDate = DateFormat(
                    'yyyy-MM-dd HH:mm:ss',
                  ).parse(rawTimestamp);
                  formattedTime = DateFormat(
                    'EEEE, MMM d • h:mm a',
                  ).format(parsedDate);
                } catch (e) {
                  formattedTime =
                      rawTimestamp; // Fallback if format parsing fails
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Card(
                    elevation: 0,
                    color: colorScheme.secondaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          child: Icon(_getMealIcon(mealType), size: 20),
                        ),
                        title: Text(
                          mealType,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                foodItems,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: colorScheme.onSecondaryContainer
                                      .withValues(alpha: 0.8),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                formattedTime,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSecondaryContainer
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
