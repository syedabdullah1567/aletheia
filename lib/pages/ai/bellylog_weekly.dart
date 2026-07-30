import 'package:aletheia/data/bellylog_database.dart';
import 'package:aletheia/utilities/uniform_appbar.dart';
import 'package:flutter/material.dart';
import '../../utilities/ai/get_gemini_response.dart';
import 'dart:convert';

class BellylogWeekly extends StatefulWidget {
  const BellylogWeekly({super.key});

  @override
  State<BellylogWeekly> createState() => _BellylogWeeklyState();
}

class _BellylogWeeklyState extends State<BellylogWeekly> {
  String? answer;
  // Set isLoading to true initially so the spinner shows immediately
  bool isLoading = true;

  final BellyLogDatabase db = BellyLogDatabase();

  @override
  void initState() {
    super.initState();
    // Trigger the API call the moment the widget is inserted into the tree
    _talkToGemini();
  }

  void _talkToGemini() async {
    db.loadData();

    final encoder = const JsonEncoder.withIndent('  ');

    final String checkinsJson = encoder.convert(db.dailyCheckins);
    final String mealsJson = encoder.convert(db.mealLog);
    final String symptomsJson = encoder.convert(db.symptomLog);
    final String bowelsJson = encoder.convert(db.bowelLog);

    final String textToSend =
        '''
Here is the user's logged data for the past week. Please analyze it according to your instructions.

--- DAILY CHECK-INS (Sleep & Stress) ---
$checkinsJson

--- MEALS LOGGED ---
$mealsJson

--- SYMPTOMS LOGGED ---
$symptomsJson

--- BOWEL MOVEMENTS ---
$bowelsJson
''';

    // Await the response
    String theAnswer = await getGeminiResponse(textToSend);

    // Only call setState if the widget is still mounted (user didn't press back while loading)
    if (mounted) {
      setState(() {
        answer = theAnswer;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: UniformAppbar(
        leadIcon: const Icon(Icons.arrow_back_rounded),
        titleText: "Weekly Insight",
        onPress: () => Navigator.pop(context),
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 24),
                  Text(
                    'Analyzing your week...',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Header Icon
                const Icon(Icons.auto_awesome, size: 48, color: Colors.pink),
                const SizedBox(height: 16),

                // Title
                Text(
                  'Your AI Summary',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Result Card
                Card(
                  elevation: 0,
                  color: theme.colorScheme.secondaryContainer.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      answer ?? 'No data could be analyzed.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.6, // Improves readability for long text
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
