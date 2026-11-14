import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> restoreHiveDatabase(BuildContext context) async {
  final backupFile = File('/storage/emulated/0/Download/MyBox.hive');

  try {
    // 1. Check if file exists and can actually be read
    if (!await backupFile.exists()) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: MyBox.hive not found in Downloads folder!'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final box = Hive.box('MyBox');
    final String? destinationPath = box.path;

    if (destinationPath != null) {
      // 2. Close box, perform the copy, and reopen immediately
      await box.close();
      await backupFile.copy(destinationPath);
      await Hive.openBox('MyBox');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Restore successful! Please restart the app to refresh views.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  } catch (e) {
    // 3. Fail-safe: Ensure the box gets re-opened if the copy fails
    if (!Hive.isBoxOpen('MyBox')) {
      await Hive.openBox('MyBox');
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Restore Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
