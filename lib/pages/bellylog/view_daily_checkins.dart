import 'package:aletheia/utilities/uniform_appbar.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class ViewDailyCheckins extends StatefulWidget {
  const ViewDailyCheckins({super.key});

  @override
  State<ViewDailyCheckins> createState() => _ViewDailyCheckins();
}

class _ViewDailyCheckins extends State<ViewDailyCheckins> {
  final Box _myBox = Hive.box('MyBox');

  List<String> sortedKeys = [];
  Map<String, dynamic> dailyCheckins = {};

  @override
  void initState() {
    super.initState();
    loadDailyCheckinsLog();
  }

  void loadDailyCheckinsLog() {
    setState(() {
      final rawData = _myBox.get('DAILYCHECKINS');
      if (rawData != null) {
        dailyCheckins = Map<String, dynamic>.from(rawData);

        sortedKeys = dailyCheckins.keys.toList()
          ..sort((a, b) => b.compareTo(a));
      } else {
        dailyCheckins = {};
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
        titleText: "View Daily Check-ins",
        onPress: () => Navigator.pop(context),
      ),

      body: sortedKeys.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.today_outlined,
                    size: 64,
                    color: colorScheme.outlineVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No check-ins logged yet!',
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
                    dailyCheckins[rawTimestamp] ?? {};
                String stressLevel = entryData['stress']?.toString() ?? '';
                double sleepHours;
                final sleepRaw = entryData['sleep'];
                if (sleepRaw is num) {
                  sleepHours = sleepRaw.toDouble();
                } else {
                  sleepHours =
                      double.tryParse(sleepRaw?.toString() ?? '') ?? 0.0;
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
                        title: Text(
                          'Stress Level: $stressLevel\nHours slept: $sleepHours',
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
