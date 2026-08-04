import 'package:flutter/material.dart';
import '../data/darkmode_database.dart';

// Check if system brightness is dark at the time of initialization
final bool isSystemDark =
    WidgetsBinding.instance.platformDispatcher.platformBrightness ==
    Brightness.dark;

ValueNotifier<bool> isDarkModeNotifier = ValueNotifier<bool>(isSystemDark);
