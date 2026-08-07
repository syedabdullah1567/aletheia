import 'dart:convert';
import 'package:aletheia/data/palimora_database.dart';
import 'package:aletheia/utilities/ai/ai_prompts.dart';
import 'package:aletheia/utilities/uniform_appbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utilities/ai/get_gemini_response.dart';

class PalimoraWeekly extends StatefulWidget {
  const PalimoraWeekly({super.key});

  @override
  State<PalimoraWeekly> createState() => _PalimoraWeeklyState();
}

class _PalimoraWeeklyState extends State<PalimoraWeekly> {
  String? answer;
  bool isLoading = true;

  String systemInstruction = AiPrompts.palimoraSystemInstruction;
  final PalimoraDatabase db = PalimoraDatabase();

  @override
  void initState() {
    super.initState();
    _talkToGemini();
  }

  void _talkToGemini() async {
    // 1. Load all data sets from Hive database
    db.loadData(1); // Moods
    db.loadData(2); // Sleep
    db.loadData(3); // Pillar Ratings
    db.loadData(4); // Journal Entries

    final encoder = JsonEncoder.withIndent('  ', (object) => object.toString());

    final DateTime now = DateTime.now();
    final DateTime sevenDaysAgo = now.subtract(const Duration(days: 7));

    // Helper closure to filter entries belonging to the past 7 days
    bool isWithinWeek(String timestampKey) {
      try {
        DateTime? parsedDate = DateTime.tryParse(timestampKey);
        if (parsedDate == null) {
          if (timestampKey.length == 10) {
            parsedDate = DateFormat('yyyy-MM-dd').parse(timestampKey);
          } else {
            parsedDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(timestampKey);
          }
        }
        return parsedDate.isAfter(sevenDaysAgo) &&
            parsedDate.isBefore(now.add(const Duration(days: 1)));
      } catch (e) {
        return false;
      }
    }

    // 2. Extract and convert Palimora data into JSON maps for the past week
    final weeklyMoods = Map.fromEntries(
      db.moods.entries.where((e) => isWithinWeek(e.key.toString())),
    );

    final weeklySleep = Map.fromEntries(
      db.sleep.entries.where((e) => isWithinWeek(e.key.toString())),
    );

    final weeklyPillarRatings = Map.fromEntries(
      db.pillarRatings.entries.where((e) => isWithinWeek(e.key.toString())),
    );

    final weeklyJournalEntries = Map.fromEntries(
      db.journalEntries.entries.where((e) => isWithinWeek(e.key.toString())),
    );

    // 3. Encode to JSON strings
    final String moodsJson = encoder.convert(weeklyMoods);
    final String sleepJson = encoder.convert(weeklySleep);
    final String pillarsJson = encoder.convert(weeklyPillarRatings);
    final String journalJson = encoder.convert(weeklyJournalEntries);

    // 4. Construct prompt payload for Gemini
    final String startDateStr = DateFormat('yyyy-MM-dd').format(sevenDaysAgo);
    final String endDateStr = DateFormat('yyyy-MM-dd').format(now);

    final String textToSend =
        '''
        Here is the user's logged Palimora data for the past 7 days (strictly from $startDateStr to $endDateStr). Please analyze it according to your instructions.

        --- MOODS LOGGED ---
        $moodsJson

        --- SLEEP METRICS ---
        $sleepJson

        --- PILLAR RATINGS ---
        $pillarsJson

        --- JOURNAL ENTRIES ---
        $journalJson
        ''';

    // 5. Send to AI
    String theAnswer = await getGeminiResponse(
      systemInstruction,
      textToSend,
      0.4,
      0.95,
      4096,
    );

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
                    'Analyzing your past week...',
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
                const Icon(Icons.auto_awesome, size: 48, color: Colors.pink),
                const SizedBox(height: 16),
                Text(
                  'Your 7-Day AI Summary',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
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
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
