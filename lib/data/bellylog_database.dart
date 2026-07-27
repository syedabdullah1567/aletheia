import 'package:hive_flutter/hive_flutter.dart';

class BellyLogDatabase {
  // Database Structures
  Map<String, dynamic> mealLog = {};
  Map<String, dynamic> symptomLog = {};
  Map<String, dynamic> bowelLog = {};
  Map<String, dynamic> dailyCheckins = {};

  // Reference the box
  final _myBox = Hive.box('MyBox');

  void createInitialData() {
    mealLog = <String, dynamic>{};
    symptomLog = <String, dynamic>{};
    bowelLog = <String, dynamic>{};
    dailyCheckins = <String, dynamic>{};
  }

  void loadData() {
    // Safely parse meals
    final rawMeals = _myBox.get('MEALLOG');
    mealLog = rawMeals != null
        ? Map<String, dynamic>.from(rawMeals)
        : <String, dynamic>{};

    // Safely parse symptoms
    final rawSymptoms = _myBox.get('SYMPTOMS');
    symptomLog = rawSymptoms != null
        ? Map<String, dynamic>.from(rawSymptoms)
        : <String, dynamic>{};

    // FIXED: Safely parse bowel movements as a Map, NOT a List!
    final rawBowelMovements = _myBox.get('BOWELMOVEMENTS');
    bowelLog = rawBowelMovements != null
        ? Map<String, dynamic>.from(rawBowelMovements)
        : <String, dynamic>{};

    final rawDailyCheckins = _myBox.get('DAILYCHECKINS');
    dailyCheckins = rawDailyCheckins != null
        ? Map<String, dynamic>.from(rawDailyCheckins)
        : <String, dynamic>{};
  }

  void updateDataBase() {
    _myBox.put('MEALLOG', mealLog);
    _myBox.put('SYMPTOMS', symptomLog);
    _myBox.put('BOWELMOVEMENTS', bowelLog);
    _myBox.put('DAILYCHECKINS', dailyCheckins);
  }
}