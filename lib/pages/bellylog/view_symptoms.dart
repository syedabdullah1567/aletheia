import 'package:aletheia/utilities/uniform_appbar.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class ViewSymptomLogs extends StatefulWidget {
  const ViewSymptomLogs({super.key});

  @override
  State<ViewSymptomLogs> createState() => _ViewSymptomLogsState();
}

class _ViewSymptomLogsState extends State<ViewSymptomLogs> {
  final Box _myBox = Hive.box('MyBox');
  List<String> sortedKeys = [];
  Map<String, dynamic> symptomLog = {};

  @override
  void initState() {
    super.initState();
    loadSymptomLog();
  }

  void loadSymptomLog() {
    setState(() {
      // Safely transform Hive's dynamic map into a strongly-typed string map
      final rawData = _myBox.get('SYMPTOMS');
      if (rawData != null) {
        symptomLog = Map<String, dynamic>.from(rawData);
        // Sort keys in descending order so the newest logs appear first
        sortedKeys = symptomLog.keys.toList()..sort((a, b) => b.compareTo(a));
      } else {
        symptomLog = {};
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
        titleText: "View Symptoms",
        onPress: () => Navigator.pop(context),
      ),
      body: sortedKeys.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.healing,
                    size: 64,
                    color: colorScheme.outlineVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No symptoms logged yet!',
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
                Map<dynamic, dynamic> entryData =
                    symptomLog[rawTimestamp] ?? {};

                List<dynamic> rawSymptoms =
                    entryData['selected_symptoms'] ?? [];
                List<String> symptoms = rawSymptoms
                    .map((item) => item?.toString() ?? '')
                    .where((item) => item.isNotEmpty)
                    .toList();
                String others = entryData['other_symptoms'] ?? '';
                String symptomText = symptoms.join(', ');
                if (others.isNotEmpty) {
                  symptomText = symptomText.isNotEmpty
                      ? '$symptomText, $others'
                      : others;
                }

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
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                symptomText,
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
