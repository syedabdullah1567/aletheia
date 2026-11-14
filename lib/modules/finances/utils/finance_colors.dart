import 'package:flutter/material.dart';

/// Red = money I owe / spent. Green = money owed to me / earned.
/// Shades are picked per brightness so they stay readable in dark mode.
Color financeRed(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? Colors.red.shade300
        : Colors.red.shade700;

Color financeGreen(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? Colors.green.shade300
        : Colors.green.shade700;
