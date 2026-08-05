import 'package:aletheia/data/bellylog_database.dart';
import 'package:aletheia/utilities/uniform_appbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utilities/ai/get_gemini_response.dart';
import 'dart:convert';

class BellylogDaily extends StatefulWidget {
  const BellylogDaily({super.key});

  @override
  State<BellylogDaily> createState() => _BellylogDailyState();
}

class _BellylogDailyState extends State<BellylogDaily> {
  String? answer;
  // Set isLoading to true initially so the spinner shows immediately
  bool isLoading = true;

  String systemInstruction = """
          You are BellyLog, an AI digestive health assistant inside the Aletheia app.

          Your job is to analyze the user's BellyLog records and identify meaningful patterns.

          Rules:
          - Never diagnose diseases.
          - Never recommend medication.
          - Never claim certainty when there is insufficient evidence.
          - Base every observation only on the provided data.
          - If no obvious pattern exists, clearly state that.
          - Mention possible food-symptom relationships only when supported by the data.
          - End with 2-3 practical observations the user can monitor over the next few days.
          - Keep the response under 300 words.
          - Respond in plain English.
          - Do not use Markdown, headings, tables or code blocks.
          - You may use only bullet points and text formatting of the form that could be understood by a very basic flutter text display
          """;

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

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final todaysCheckins = Map.fromEntries(
      db.dailyCheckins.entries.where((entry) => entry.key.startsWith(today)),
    );

    final todaysMeals = Map.fromEntries(
      db.mealLog.entries.where((entry) => entry.key.startsWith(today)),
    );

    final todaysSymptoms = Map.fromEntries(
      db.symptomLog.entries.where((entry) => entry.key.startsWith(today)),
    );

    final todaysBowels = Map.fromEntries(
      db.bowelLog.entries.where((entry) => entry.key.startsWith(today)),
    );

    final String checkinsJson = encoder.convert(todaysCheckins);
    final String mealsJson = encoder.convert(todaysMeals);
    final String symptomsJson = encoder.convert(todaysSymptoms);
    final String bowelsJson = encoder.convert(todaysBowels);

    final String textToSend =
        '''
Here is the user's logged data for today. Please analyze it according to your instructions.

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
    String theAnswer = await getGeminiResponse(systemInstruction, textToSend);

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
        titleText: "Daily Insight",
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
                  color: theme.colorScheme.secondaryContainer.withValues(
                    alpha: 0.4,
                  ),
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
