import 'package:flutter/material.dart';
import '../data/darkmode_database.dart';

DarkmodeDatabase db = DarkmodeDatabase();

ValueNotifier<bool> isDarkModeNotifier = ValueNotifier(db.isDark);
