import 'package:hive/hive.dart';

class PalimoraDatabase {
  final _myBox = Hive.box('MyBox');

  // Daily reset hour (9:00 AM)
  static const int resetHour = 9;

  Map<String, String> moods = {};
  Map<String, Map<String, double>> sleep = {};
  Map<String, Map<String, double>> pillarRatings = {};
  Map<String, String> journalEntries = {};

  /// 1. Get the current active logging cycle identifier (YYYY-MM-DD string)
  String get currentCycleKey {
    final now = DateTime.now();
    // If before 9:00 AM, the active cycle belongs to yesterday
    final cycleDate = now.hour < resetHour
        ? now.subtract(const Duration(days: 1))
        : now;

    return "${cycleDate.year}-${cycleDate.month.toString().padLeft(2, '0')}-${cycleDate.day.toString().padLeft(2, '0')}";
  }

  /// 2. Dynamically calculate whether the user has logged for the current 9 AM cycle
  bool get hasLogged {
    final lastLoggedCycle = _myBox.get('LAST_LOGGED_CYCLE', defaultValue: '');
    return lastLoggedCycle == currentCycleKey;
  }

  /// 3. Mark today's cycle as completed
  void markAsLogged() {
    _myBox.put('LAST_LOGGED_CYCLE', currentCycleKey);
  }

  void createInitialData(int num) {
    if (num == 0) {
      _myBox.delete('LAST_LOGGED_CYCLE');
    } else if (num == 1) {
      moods = {};
    } else if (num == 2) {
      sleep = {};
    } else if (num == 3) {
      pillarRatings = {};
    } else if (num == 4) {
      journalEntries = {};
    }
  }

  void loadData(int num) {
    if (num == 0) {
      // Nothing needed here since `hasLogged` is a getter now!
    } else if (num == 1) {
      final rawMoods = _myBox.get('MOODS');
      moods = rawMoods == null
          ? <String, String>{}
          : Map<String, String>.from(rawMoods);
    } else if (num == 2) {
      final rawSleep = _myBox.get('SLEEP') as Map?;
      sleep = rawSleep != null
          ? rawSleep.map(
              (k, v) =>
                  MapEntry(k.toString(), Map<String, double>.from(v as Map)),
            )
          : {};
    } else if (num == 3) {
      final rawRatings = _myBox.get('PILLARRATINGS') as Map?;
      pillarRatings = rawRatings != null
          ? rawRatings.map(
              (k, v) =>
                  MapEntry(k.toString(), Map<String, double>.from(v as Map)),
            )
          : {};
    } else if (num == 4) {
      final rawjournalEntries = _myBox.get('JOURNALENTRIES');
      journalEntries = rawjournalEntries == null
          ? <String, String>{}
          : Map<String, String>.from(rawjournalEntries);
    }
  }

  void updateDataBase(int num) {
    if (num == 0) {
      markAsLogged();
    } else if (num == 1) {
      _myBox.put('MOODS', moods);
    } else if (num == 2) {
      _myBox.put('SLEEP', sleep);
    } else if (num == 3) {
      _myBox.put('PILLARRATINGS', pillarRatings);
    } else if (num == 4) {
      _myBox.put('JOURNALENTRIES', journalEntries);
    }
  }
}
