import 'dart:convert';
import 'package:aletheia/utilities/ai/ai_prompts.dart';
import 'package:aletheia/utilities/context_service.dart';
import 'package:flutter/foundation.dart';
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

  /// Converted to a getter so userContext is lazily evaluated at runtime
  String get systemInstruction {
    // Safe null-coalescing check
    /// Safely fetches userContext without blowing up if ContextService is empty/null
    String personalContext = '';

    try {
      personalContext = ContextService.userContext ?? '';
      print(personalContext);
    } catch (e) {
      print('⚠️ Warning: Could not load ContextService.userContext: $e');
      personalContext = 'No extra personal context available.';
    }

    return AiPrompts.aletheiaWeeklySystemInstruction(personalContext);
  }

  Future<String> fetchWeeklyInsight() async {
    try {
      // 1. Load data from all 3 databases
      todoDb.loadToDo();
      todoDb.loadLongTerm();

      bellyDb.loadData();

      palimoraDb.loadData(1); // Moods
      palimoraDb.loadData(2); // Sleep
      palimoraDb.loadData(3); // Pillar Ratings
      palimoraDb.loadData(4); // Journal Entries

      // 2. Define the date range for the past 7 days
      final DateTime now = DateTime.now();
      final DateTime sevenDaysAgo = now.subtract(const Duration(days: 7));

      // Safe multi-format date parser
      bool isWithinPast7Days(String dateStr) {
        try {
          DateTime? parsedDate = DateTime.tryParse(dateStr);
          if (parsedDate == null) {
            if (dateStr.length == 10) {
              parsedDate = DateFormat('yyyy-MM-dd').parse(dateStr);
            } else {
              parsedDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateStr);
            }
          }
          return parsedDate.isAfter(sevenDaysAgo) &&
              parsedDate.isBefore(now.add(const Duration(days: 1)));
        } catch (e) {
          return false;
        }
      }

      // 3. Extract & filter ToDo Data safely
      final List rawTodoList = (todoDb.todoList as dynamic) ?? [];
      final List rawLongTerm = (todoDb.longTerm as dynamic) ?? [];

      final filteredTodoList = rawTodoList
          .where((item) {
            if (item is List && item.length >= 3) {
              final taskDate = item[2] is DateTime
                  ? item[2] as DateTime
                  : DateTime.tryParse(item[2].toString());
              if (taskDate != null) {
                return taskDate.isAfter(sevenDaysAgo) &&
                    taskDate.isBefore(now.add(const Duration(days: 1)));
              }
            }
            return false;
          })
          .map((item) {
            final taskList = item as List;
            final taskDate = taskList[2] is DateTime
                ? taskList[2] as DateTime
                : DateTime.tryParse(taskList[2].toString());
            return {
              'task': taskList[0]?.toString() ?? '',
              'completed': taskList[1] == true,
              'timestamp': taskDate?.toIso8601String() ?? '',
              'priority': taskList.length > 3 ? taskList[3] : 0,
            };
          })
          .toList();

      final filteredLongTerm = rawLongTerm
          .where((item) {
            if (item is List && item.length >= 3) {
              final taskDate = item[2] is DateTime
                  ? item[2] as DateTime
                  : DateTime.tryParse(item[2].toString());
              if (taskDate != null) {
                return taskDate.isAfter(sevenDaysAgo) &&
                    taskDate.isBefore(now.add(const Duration(days: 1)));
              }
            }
            return false;
          })
          .map((item) {
            final taskList = item as List;
            final taskDate = taskList[2] is DateTime
                ? taskList[2] as DateTime
                : DateTime.tryParse(taskList[2].toString());
            return {
              'task': taskList[0]?.toString() ?? '',
              'completed': taskList[1] == true,
              'timestamp': taskDate?.toIso8601String() ?? '',
              'priority': taskList.length > 3 ? taskList[3] : 0,
            };
          })
          .toList();

      // 4. Extract & filter BellyLog Data
      final Map rawMeals = (bellyDb.mealLog as dynamic) ?? {};
      final Map rawSymptoms = (bellyDb.symptomLog as dynamic) ?? {};
      final Map rawBowel = (bellyDb.bowelLog as dynamic) ?? {};
      final Map rawDailyCheckins = (bellyDb.dailyCheckins as dynamic) ?? {};

      final filteredMeals = Map.fromEntries(
        rawMeals.entries.where((e) => isWithinPast7Days(e.key.toString())),
      );
      final filteredSymptoms = Map.fromEntries(
        rawSymptoms.entries.where((e) => isWithinPast7Days(e.key.toString())),
      );
      final filteredBowel = Map.fromEntries(
        rawBowel.entries.where((e) => isWithinPast7Days(e.key.toString())),
      );
      final filteredDailyCheckins = Map.fromEntries(
        rawDailyCheckins.entries.where(
          (e) => isWithinPast7Days(e.key.toString()),
        ),
      );

      // 5. Extract & filter Palimora Data
      final Map rawMoods = (palimoraDb.moods as dynamic) ?? {};
      final Map rawSleep = (palimoraDb.sleep as dynamic) ?? {};
      final Map rawPillarRatings = (palimoraDb.pillarRatings as dynamic) ?? {};
      final Map rawJournalEntries =
          (palimoraDb.journalEntries as dynamic) ?? {};

      final filteredMoods = Map.fromEntries(
        rawMoods.entries.where((e) => isWithinPast7Days(e.key.toString())),
      );
      final filteredSleep = Map.fromEntries(
        rawSleep.entries.where((e) => isWithinPast7Days(e.key.toString())),
      );
      final filteredPillarRatings = Map.fromEntries(
        rawPillarRatings.entries.where(
          (e) => isWithinPast7Days(e.key.toString()),
        ),
      );
      final filteredJournalEntries = Map.fromEntries(
        rawJournalEntries.entries.where(
          (e) => isWithinPast7Days(e.key.toString()),
        ),
      );

      // 6. Safe JSON encoder with fallback
      final encoder = JsonEncoder((object) => object.toString());

      final String summary = encoder.convert({
        "summary": {
          "todo_entries": filteredTodoList.length,
          "long_term_entries": filteredLongTerm.length,
          "meal_entries": filteredMeals.length,
          "symptom_entries": filteredSymptoms.length,
          "bowel_entries": filteredBowel.length,
          "journal_entries": filteredJournalEntries.length,
          "mood_entries": filteredMoods.length,
        },
      });

      final String todoJson = encoder.convert({
        'daily_tasks': filteredTodoList,
        'long_term_tasks': filteredLongTerm,
      });

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

      // 7. Format prompt payload
      final String startDateStr = DateFormat('yyyy-MM-dd').format(sevenDaysAgo);
      final String endDateStr = DateFormat('yyyy-MM-dd').format(now);

      final String promptText =
          '''
[DATE RANGE OF LOGS]
The following dataset contains user activity recorded over the past 7 days, strictly from $startDateStr to $endDateStr.

======================================================================
SUMMARY
======================================================================
$summary

======================================================================
1. CHECKPOINTS MODULE
======================================================================
$todoJson

======================================================================
2. BELLYLOG MODULE
======================================================================
$bellyLogJson

======================================================================
3. PALIMORA MODULE
======================================================================
$palimoraJson
''';

      // 8. Execute API call
      return await getGeminiResponse(
        systemInstruction,
        promptText,
        0.4,
        0.95,
        4096,
      );
    } catch (e, stackTrace) {
      print('❌ Error inside fetchWeeklyInsight: $e');
      print(stackTrace);
      rethrow;
    }
  }
}
