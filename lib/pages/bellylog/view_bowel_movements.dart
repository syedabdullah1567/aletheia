import 'package:aletheia/utilities/uniform_appbar.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class ViewBowelMovementLogs extends StatefulWidget {
  const ViewBowelMovementLogs({super.key});

  @override
  State<ViewBowelMovementLogs> createState() => _ViewBowelMovementLogsState();
}

class _ViewBowelMovementLogsState extends State<ViewBowelMovementLogs> {
  final Box _myBox = Hive.box('MyBox');
  List<String> sortedKeys = [];
  Map<String, dynamic> bowelLog = {};

  @override
  void initState() {
    super.initState();
    loadBowelMovementLog();
  }

  void loadBowelMovementLog() {
    setState(() {
      // Safely transform Hive's dynamic map into a strongly-typed string map
      final rawData = _myBox.get('BOWELMOVEMENTS');
      if (rawData != null) {
        bowelLog = Map<String, dynamic>.from(rawData);
        // Sort keys in descending order so the newest logs appear first
        sortedKeys = bowelLog.keys.toList()..sort((a, b) => b.compareTo(a));
      } else {
        bowelLog = {};
        sortedKeys = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: UniformAppbar(
        leadIcon: Icon(Icons.arrow_back_rounded),
        titleText: "View Bathroom Visits",
        onPress: () => Navigator.pop(context),
      ),
      body: sortedKeys.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wc, size: 64, color: colorScheme.outlineVariant),
                  const SizedBox(height: 16),
                  Text(
                    'No bowel movements logged yet!',
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
                Map<dynamic, dynamic> entryData = bowelLog[rawTimestamp] ?? {};
                String stoolType = entryData['type'] ?? '';
                String urgency = entryData['urgency'] ?? '';

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
                        title: Text(
                          'Bristol chart stool type: $stoolType\nUrgency: $urgency',
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
