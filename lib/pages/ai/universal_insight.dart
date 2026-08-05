import 'dart:convert';
import 'package:intl/intl.dart';

// Import your Database files
import 'package:aletheia/data/bellylog_database.dart';
import 'package:aletheia/data/palimora_database.dart';
import 'package:aletheia/data/todo_database.dart';
import 'package:aletheia/utilities/ai/get_gemini_response.dart';

class WeeklyInsightService {
  final BellyLogDatabase bellyDb = BellyLogDatabase();
  final PalimoraDatabase palimoraDb = PalimoraDatabase();
  final ToDoDataBase todoDb = ToDoDataBase();

  /// System instruction variable left empty as requested.
  final String systemInstruction = '''
    The following context is what ill be using you for, but right now im doing a test run only.
    You are Aletheia, a mature personal life analysis assistant. Your purpose is not to judge, diagnose, motivate aggressively, or give generic advice. Your purpose is to analyze patterns across a person's actions, physical health, emotions, routines, and life choices to help them better understand themselves.

    You are analyzing a user's complete Aletheia data ecosystem, which includes:

    1. Checkpoints Module:

    - Tasks completed and missed
    - Long-term goals
    - Habits and consistency
    - Productivity patterns
    - Progress over time
    - Areas where the user follows through or struggles

    2. BellyLog Module:

    - Meals and dietary patterns
    - Digestive symptoms
    - Bowel movements
    - IBS-related observations
    - Sleep quality
    - Stress levels
    - Symptom severity
    - Possible correlations between lifestyle choices and physical symptoms

    3. Palimora Module:

    - Journals and personal reflections
    - Mood tracking
    - Emotional patterns
    - Life pillar tracking
    - Sources of happiness, frustration, sadness, stress, or motivation

    Analyze all information together. Do not treat these modules as separate. Look for relationships between them.

    For example:

    - Does sleep quality influence mood, productivity, or digestive symptoms?
    - Do stressful periods correlate with physical symptoms?
    - Are productive days associated with certain routines?
    - Are certain habits consistently linked with better or worse days?
    - What patterns appear repeatedly over weeks or months?

    User background and context:

    The user is a Computer Science student focused on mobile development with Flutter. They enjoy understanding how computers, software, and AI work. They are building Aletheia as a personal system to understand themselves through data rather than simply as a productivity tool.

    The user previously created individual concepts:

    - Checkpoints: a daily task and long-term goal tracking system.
    - BellyLog: a digestive health and lifestyle tracking system.
    - Palimora: an AI-powered personal pattern detection and reflection system.

    These were unified into Aletheia because the user believes actions, physical state, and mental state are interconnected.

    The user has a history of IBS-D diagnosis and has experienced recurring digestive issues. They have noticed symptoms can worsen after certain foods, large meals, unhealthy eating periods, stressful situations, and poor lifestyle choices. Previous medical evaluations included blood tests and allergy testing, but the user is interested in better understanding personal patterns through consistent tracking. Do not diagnose medical conditions. Only identify patterns and suggest observations.

    The user values self-awareness and reflection. They prefer realistic, thoughtful analysis rather than exaggerated motivational language. Avoid making assumptions about personality or giving unnecessary life advice. Focus on evidence from the data.

    Your analysis should include:

    1. Overall Life Pattern:
      Explain the general state of the user's life based on the available data.

    2. Physical Health Patterns:
      Identify trends related to digestion, food, sleep, stress, and symptoms. Mention possible correlations, not medical conclusions.

    3. Productivity and Goal Patterns:
      Analyze consistency, habits, completed goals, setbacks, and factors affecting progress.

    4. Emotional and Mental Patterns:
      Analyze moods, journal entries, emotional triggers, and sources of satisfaction or stress.

    5. Cross-Domain Insights:
      Identify connections between different areas of life.

    6. Areas of Improvement:
      Suggest practical areas to observe or improve, based only on patterns found.

    7. Positive Patterns:
      Highlight what appears to be working well.

    8. Reflection Questions:
      End with a few thoughtful questions that encourage self-awareness.

    Important rules:

    - Stay mature, calm, and analytical.
    - Do not use a motivational speaker tone.
    - Do not diagnose diseases or make medical claims.
    - Do not assume a correlation is a proven cause.
    - Avoid generic advice that could apply to anyone.
    - Base insights on the user's actual data.
    - If insufficient data exists, clearly state that more data is needed.
    - Do not use markdown formatting.
    - Do not use bullet points, headings, emojis, or special formatting.
    - Write naturally as a thoughtful personal analysis.
    - Keep the response between 600 and 700 words maximum.
    - The goal is not to tell the user what to do, but to help them see their own patterns more clearly.
    ''';

  Future<String> fetchWeeklyInsight() async {
    // 1. Load data from all 3 databases
    bellyDb.loadData();

    palimoraDb.loadData(1); // Moods
    palimoraDb.loadData(2); // Sleep
    palimoraDb.loadData(3); // Pillar Ratings
    palimoraDb.loadData(4); // Journal Entries

    todoDb.loadToDo();
    todoDb.loadLongTerm();

    // 2. Define the date range for the past 7 days
    final DateTime now = DateTime.now();
    final DateTime sevenDaysAgo = now.subtract(const Duration(days: 7));

    // Helper: Check if a key (e.g., "2026-07-20 08:00:00" or "2026-07-20") falls within the last 7 days
    bool isWithinPast7Days(String dateStr) {
      try {
        DateTime parsedDate;
        if (dateStr.length == 10) {
          parsedDate = DateFormat('yyyy-MM-dd').parse(dateStr);
        } else {
          parsedDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateStr);
        }
        return parsedDate.isAfter(sevenDaysAgo) &&
            parsedDate.isBefore(now.add(const Duration(days: 1)));
      } catch (e) {
        return false;
      }
    }

    // 3. Extract & filter BellyLog Data (Past 7 Days)
    final filteredMeals = Map.fromEntries(
      bellyDb.mealLog.entries.where((e) => isWithinPast7Days(e.key)),
    );
    final filteredSymptoms = Map.fromEntries(
      bellyDb.symptomLog.entries.where((e) => isWithinPast7Days(e.key)),
    );
    final filteredBowel = Map.fromEntries(
      bellyDb.bowelLog.entries.where((e) => isWithinPast7Days(e.key)),
    );
    final filteredDailyCheckins = Map.fromEntries(
      bellyDb.dailyCheckins.entries.where((e) => isWithinPast7Days(e.key)),
    );

    // 4. Extract & filter Palimora Data (Past 7 Days)
    final filteredMoods = Map.fromEntries(
      palimoraDb.moods.entries.where((e) => isWithinPast7Days(e.key)),
    );
    final filteredSleep = Map.fromEntries(
      palimoraDb.sleep.entries.where((e) => isWithinPast7Days(e.key)),
    );
    final filteredPillarRatings = Map.fromEntries(
      palimoraDb.pillarRatings.entries.where((e) => isWithinPast7Days(e.key)),
    );
    final filteredJournalEntries = Map.fromEntries(
      palimoraDb.journalEntries.entries.where((e) => isWithinPast7Days(e.key)),
    );

    // 5. Extract & filter ToDo Data (Past 7 Days)
    // Structure: [taskTitle, isCompleted, DateTime timestamp, priority]
    final filteredTodoList = todoDb.todoList
        .where((item) {
          if (item is List && item.length >= 3 && item[2] is DateTime) {
            final DateTime taskDate = item[2];
            return taskDate.isAfter(sevenDaysAgo) &&
                taskDate.isBefore(now.add(const Duration(days: 1)));
          }
          return false;
        })
        .map(
          (item) => {
            'task': item[0],
            'completed': item[1],
            'timestamp': (item[2] as DateTime).toIso8601String(),
            'priority': item.length > 3 ? item[3] : 0,
          },
        )
        .toList();

    final filteredLongTerm = todoDb.longTerm
        .where((item) {
          if (item is List && item.length >= 3 && item[2] is DateTime) {
            final DateTime taskDate = item[2];
            return taskDate.isAfter(sevenDaysAgo) &&
                taskDate.isBefore(now.add(const Duration(days: 1)));
          }
          return false;
        })
        .map(
          (item) => {
            'task': item[0],
            'completed': item[1],
            'timestamp': (item[2] as DateTime).toIso8601String(),
            'priority': item.length > 3 ? item[3] : 0,
          },
        )
        .toList();

    // 6. Convert aggregated datasets to clean JSON strings
    const encoder = JsonEncoder.withIndent('  ');

    final String bellyLogJson = encoder.convert({
      'meals': filteredMeals,
      'symptoms': filteredSymptoms,
      'bowel_movements': filteredBowel,
      'daily_checkins': filteredDailyCheckins,
    });

    final String palimoraJson = encoder.convert({
      'moods': filteredMoods,
      'sleep': filteredSleep,
      'pillar_ratings': filteredPillarRatings,
      'journal_entries': filteredJournalEntries,
    });

    final String todoJson = encoder.convert({
      'daily_tasks': filteredTodoList,
      'long_term_tasks': filteredLongTerm,
    });

    // 7. Format the complete prompt payload for Gemini
    final String startDateStr = DateFormat('yyyy-MM-dd').format(sevenDaysAgo);
    final String endDateStr = DateFormat('yyyy-MM-dd').format(now);

    final String promptText =
        '''
[DATE RANGE OF LOGS]
The following dataset contains user activity recorded over the past 7 days, strictly from $startDateStr to $endDateStr.

======================================================================
1. BELLYLOG DATA (GI Symptoms, Meals & Bowel Movements)
======================================================================
$bellyLogJson

======================================================================
2. PALIMORA DATA (Moods, Sleep Metrics, Life Pillars & Journal Entries)
======================================================================
$palimoraJson

======================================================================
3. TODO & TASK DATA (Completed Tasks & Long-Term Goals)
======================================================================
$todoJson
''';

    // 8. Execute request to Gemini API
    return await getGeminiResponse(systemInstruction, promptText);
  }
}
