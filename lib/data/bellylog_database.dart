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

    // Safely parse bowel movements
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

  // ===========================================================================
  // TEST DATA SEEDING & CLEANUP (Easily removable)
  // ===========================================================================

  /// Call this function once to inject 7 days of realistic, correlated GI data.
  void seedTest7DayData() {
    // -------------------------------------------------------------------------
    // DAY 1 (Baseline / Good Day)
    // Diet: Safe, low-FODMAP foods. Sleep: 7.5 hrs, Stress: 2.
    // Result: Normal digestion, no severe symptoms.
    // -------------------------------------------------------------------------
    dailyCheckins['2026-07-20 08:00:00'] = {'stress': '2', 'sleep': 7.5};
    mealLog['2026-07-20 08:30:00'] = {
      'type': 'Breakfast',
      'items': 'Oatmeal with berries and almond milk',
    };
    mealLog['2026-07-20 13:00:00'] = {
      'type': 'Lunch',
      'items': 'Grilled chicken salad with olive oil',
    };
    mealLog['2026-07-20 19:30:00'] = {
      'type': 'Dinner',
      'items': 'White rice and baked salmon',
    };
    bowelLog['2026-07-20 09:15:00'] = {'type': 'Type 4', 'urgency': 'Normal'};

    // -------------------------------------------------------------------------
    // DAY 2 (Lactose Trigger Case)
    // Diet: Heavy Dairy (Creamy Pasta & Ice Cream at 19:00).
    // Symptom: Severe Bloating & Gas (~2.5 hours later).
    // Bowel: Urgent Type 6 stool shortly after symptoms.
    // -------------------------------------------------------------------------
    dailyCheckins['2026-07-21 08:00:00'] = {'stress': '3', 'sleep': 7.0};
    mealLog['2026-07-21 08:30:00'] = {
      'type': 'Breakfast',
      'items': 'Scrambled eggs and toast',
    };
    mealLog['2026-07-21 13:15:00'] = {
      'type': 'Lunch',
      'items': 'Turkey sandwich on sourdough',
    };
    mealLog['2026-07-21 19:00:00'] = {
      'type': 'Dinner',
      'items': 'Creamy Alfredo Pasta and vanilla ice cream',
    };
    symptomLog['2026-07-21 21:30:00'] = {
      'selected_symptoms': ['Bloating', 'Gas', 'Abdominal Cramps'],
      'other_symptoms': 'Stomach gurgling loudly',
    };
    bowelLog['2026-07-21 22:15:00'] = {'type': 'Type 6', 'urgency': 'Urgent'};

    // -------------------------------------------------------------------------
    // DAY 3 (High Stress + Sleep Deprivation + Spicy/Greasy Food Trigger)
    // Sleep: 5.0 hours (Requested 5 hr day). Stress: 5 (Very high).
    // Diet: Spicy Pepperoni Pizza & Coffee.
    // Symptom: Nausea, Heartburn, Acid Reflux, Severe Pain.
    // Bowel: Very Urgent Type 7 (Diarrhea) multiple times.
    // -------------------------------------------------------------------------
    dailyCheckins['2026-07-22 07:30:00'] = {'stress': '5', 'sleep': 5.0};
    mealLog['2026-07-22 08:00:00'] = {
      'type': 'Breakfast',
      'items': 'Double Espresso on an empty stomach',
    };
    mealLog['2026-07-22 12:30:00'] = {
      'type': 'Lunch',
      'items': 'Spicy Pepperoni Pizza with garlic dipping sauce',
    };
    symptomLog['2026-07-22 14:00:00'] = {
      'selected_symptoms': ['Heartburn', 'Nausea', 'Sharp Pain'],
      'other_symptoms': 'Acid reflux',
    };
    bowelLog['2026-07-22 14:45:00'] = {
      'type': 'Type 7',
      'urgency': 'Very Urgent',
    };
    mealLog['2026-07-22 19:00:00'] = {
      'type': 'Dinner',
      'items': 'Plain white toast and chamomile tea',
    };
    bowelLog['2026-07-22 21:00:00'] = {'type': 'Type 6', 'urgency': 'Urgent'};

    // -------------------------------------------------------------------------
    // DAY 4 (Delayed Permutation: Late Onset FODMAP/Garlic reaction)
    // Diet: Garlic bread and onion heavy meal at Lunch.
    // Symptom: No immediate symptoms, but severe bloating & discomfort next morning/overnight.
    // Bowel: Delayed urgency next morning.
    // -------------------------------------------------------------------------
    dailyCheckins['2026-07-23 08:00:00'] = {'stress': '2', 'sleep': 8.0};
    mealLog['2026-07-23 09:00:00'] = {
      'type': 'Breakfast',
      'items': 'Smoothie with banana and protein powder',
    };
    mealLog['2026-07-23 13:30:00'] = {
      'type': 'Lunch',
      'items': 'Garlic butter pasta with French onion soup',
    };
    mealLog['2026-07-23 20:00:00'] = {
      'type': 'Dinner',
      'items': 'Steak with grilled asparagus',
    };
    symptomLog['2026-07-23 23:30:00'] = {
      'selected_symptoms': ['Bloating', 'Fullness'],
      'other_symptoms': 'Heavy feeling in upper abdomen',
    };

    // -------------------------------------------------------------------------
    // DAY 5 (Recovery / Clean Eating / Mild Bowel Residual)
    // Diet: Bland diet (BRAT-style). Sleep: 8.5 hrs, Stress: 1.
    // Result: Gradual normalization, minor lingering constipation/type 2 stool.
    // -------------------------------------------------------------------------
    dailyCheckins['2026-07-24 08:00:00'] = {'stress': '1', 'sleep': 8.5};
    mealLog['2026-07-24 08:30:00'] = {
      'type': 'Breakfast',
      'items': 'Boiled eggs and bananas',
    };
    mealLog['2026-07-24 13:00:00'] = {
      'type': 'Lunch',
      'items': 'Chicken soup with carrots and rice',
    };
    mealLog['2026-07-24 19:00:00'] = {
      'type': 'Dinner',
      'items': 'Mashed potatoes and steamed cod',
    };
    bowelLog['2026-07-24 10:00:00'] = {'type': 'Type 2', 'urgency': 'Normal'};

    // -------------------------------------------------------------------------
    // DAY 6 (High Fiber Permutation + High Water Intake)
    // Diet: High fiber beans/lentils.
    // Symptom: Mild harmless gas, but normal healthy bowel movement.
    // -------------------------------------------------------------------------
    dailyCheckins['2026-07-25 08:00:00'] = {'stress': '2', 'sleep': 6.5};
    mealLog['2026-07-25 08:30:00'] = {
      'type': 'Breakfast',
      'items': 'Avocado toast on whole grain bread',
    };
    mealLog['2026-07-25 13:00:00'] = {
      'type': 'Lunch',
      'items': 'Black bean and quinoa bowl',
    };
    mealLog['2026-07-25 19:30:00'] = {
      'type': 'Dinner',
      'items': 'Grilled tofu with broccoli and brown rice',
    };
    symptomLog['2026-07-25 16:00:00'] = {
      'selected_symptoms': ['Gas'],
      'other_symptoms': '',
    };
    bowelLog['2026-07-25 09:00:00'] = {'type': 'Type 4', 'urgency': 'Normal'};

    // -------------------------------------------------------------------------
    // DAY 7 (Processed Sugar / Artificial Sweetener Permutation)
    // Diet: Sugar-free candies / Sodas.
    // Symptom: Sudden cramping and explosive bowel movement 1.5 hours later.
    // -------------------------------------------------------------------------
    dailyCheckins['2026-07-26 08:00:00'] = {'stress': '3', 'sleep': 9.0};
    mealLog['2026-07-26 09:00:00'] = {
      'type': 'Breakfast',
      'items': 'Pancakes with maple syrup',
    };
    mealLog['2026-07-26 14:00:00'] = {
      'type': 'Lunch',
      'items': 'Diet Soda and Sugar-free gummy bears',
    };
    symptomLog['2026-07-26 15:30:00'] = {
      'selected_symptoms': ['Sudden Cramping', 'Bloating'],
      'other_symptoms': 'Watery gurgling sound',
    };
    bowelLog['2026-07-26 15:50:00'] = {
      'type': 'Type 6',
      'urgency': 'Very Urgent',
    };
    mealLog['2026-07-26 19:30:00'] = {
      'type': 'Dinner',
      'items': 'Plain grilled chicken and sweet potato',
    };

    // Save test data to Hive
    updateDataBase();
  }

  /// Call this function anytime to wipe the test dataset cleanly.
  void clearTestData() {
    createInitialData();
    updateDataBase();
  }
}
