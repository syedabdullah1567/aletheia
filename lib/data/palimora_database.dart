import 'package:hive/hive.dart';

class PalimoraDatabase {
  bool hasLogged = false;

  Map<String, String> moods = {};

  // Outer Key: timestamp, Inner Key: 'hoursSlept' / 'qualityOfSleep', Inner Value: double
  Map<String, Map<String, double>> sleep = {};

  Map<String, Map<String, double>> pillarRatings = {};

  Map<String, String> journalEntries = {};

  final _myBox = Hive.box('MyBox');

  void createInitialData(int num) {
    num == 0
        ? hasLogged = false
        : num == 1
        ? moods = {}
        : num == 2
        ? sleep = {}
        : num == 3
        ? pillarRatings = {}
        : journalEntries = {};
  }

  void loadData(int num) {
    if (num == 0) {
      hasLogged = _myBox.get('HASLOGGED', defaultValue: false);
    } else if (num == 1) {
      final rawMoods = _myBox.get('MOODS');
      moods = rawMoods == null
          ? <String, String>{}
          : Map<String, String>.from(rawMoods);
    } else if (num == 2) {
      final rawSleep = _myBox.get('SLEEP') as Map?;

      // FIXED: Cast inner map to Map<String, double> to match field declaration
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
      _myBox.put('HASLOGGED', hasLogged);
    } else if (num == 1) {
      _myBox.put('MOODS', moods);
    } else if (num == 2) {
      // FIXED: Added missing save condition for sleep database
      _myBox.put('SLEEP', sleep);
    } else if (num == 3) {
      _myBox.put('PILLARRATINGS', pillarRatings);
    } else if (num == 4) {
      _myBox.put('JOURNALENTRIES', journalEntries);
    }
  }
}
