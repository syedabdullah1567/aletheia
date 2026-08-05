import 'dart:convert';
import 'package:aletheia/data/palimora_database.dart';
import 'package:aletheia/utilities/uniform_appbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utilities/ai/get_gemini_response.dart';

class GetPalimoraInsight extends StatefulWidget {
  const GetPalimoraInsight({super.key});

  @override
  State<GetPalimoraInsight> createState() => _GetPalimoraInsightState();
}

class _GetPalimoraInsightState extends State<GetPalimoraInsight> {
  String? answer;
  bool isLoading = true;

  String systemInstruction = """
          You are Palimora, an AI personal life tracking assistant inside the Aletheia app.

          Your job is to analyze the given user data in the form of a daily log, and then a journal entry to go alongside it,
          then give the user a detailed and apt helpful analysis. You don't have to sugarcoat anything as the user is mature.
          So you should be mature as well and point the user in the right direction.

          - Respond in plain English.
          - Do not use Markdown, headings, tables or code blocks.
          - You may use only bullet points and text formatting of the form that could be understood by a very basic flutter text display.
          - Keep your analysis concise and under 500 words total.        
          """;

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

    final encoder = const JsonEncoder.withIndent('  ');

    // Get active cycle date prefix (e.g. "YYYY-MM-DD")
    final String activeCycle = db.currentCycleKey;

    // Helper closure to filter entries belonging to today's active cycle
    bool isToday(String timestampKey) {
      // Matches timestamps starting with active cycle date, or parses fallback
      if (timestampKey.startsWith(activeCycle)) return true;
      try {
        final entryDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(timestampKey);
        final cycleDate = entryDate.hour < PalimoraDatabase.resetHour
            ? entryDate.subtract(const Duration(days: 1))
            : entryDate;
        final entryCycleKey = DateFormat('yyyy-MM-dd').format(cycleDate);
        return entryCycleKey == activeCycle;
      } catch (e) {
        return false;
      }
    }

    // 2. Extract and convert Palimora data into JSON maps
    final todayMoods = Map.fromEntries(
      db.moods.entries.where((e) => isToday(e.key)),
    );

    final todaySleep = Map.fromEntries(
      db.sleep.entries.where((e) => isToday(e.key)),
    );

    final todayPillarRatings = Map.fromEntries(
      db.pillarRatings.entries.where((e) => isToday(e.key)),
    );

    final todayJournalEntries = Map.fromEntries(
      db.journalEntries.entries.where((e) => isToday(e.key)),
    );

    // 3. Encode to JSON strings
    final String moodsJson = encoder.convert(todayMoods);
    final String sleepJson = encoder.convert(todaySleep);
    final String pillarsJson = encoder.convert(todayPillarRatings);
    final String journalJson = encoder.convert(todayJournalEntries);

    // 4. Construct prompt payload for Gemini
    final String textToSend =
        '''
        Here is the user's logged data for today (${db.currentCycleKey}). Please analyze it according to your instructions.

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
    String theAnswer = await getGeminiResponse(systemInstruction, textToSend);

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
                    'Analyzing your day...',
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
                  'Your AI Summary',
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
