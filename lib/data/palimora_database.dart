import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class PalimoraDatabase {
  bool hasLogged = false;

  Map<String, String> moods = {};

  Map<String, Map<String, double>> pillarRatings = {};

  final _myBox = Hive.box('MyBox');

  void createInitialData(int num) {
    num == 0
        ? hasLogged = false
        : num == 1
        ? moods = {}
        : pillarRatings = {};
  }

  void loadData(int num) {
    if (num == 0) {
      hasLogged = _myBox.get('HASLOGGED');
    } else if (num == 1) {
      final rawMoods = _myBox.get('MOODS');

      moods = rawMoods == null
          ? <String, String>{}
          : Map<String, String>.from(rawMoods);
    } else {
      final rawRatings = _myBox.get('PILLARRATINGS') as Map?;

      pillarRatings = rawRatings != null
          ? rawRatings.map(
              (k, v) =>
                  MapEntry(k.toString(), Map<String, double>.from(v as Map)),
            )
          : {};
    }
  }

  void updateDataBase(int num) {
    if (num == 0) {
      _myBox.put('HASLOGGED', hasLogged);
    } else if (num == 1) {
      _myBox.put('MOODS', moods);
    } else {
      _myBox.put('PILLARRATINGS', pillarRatings);
    }
  }
}
