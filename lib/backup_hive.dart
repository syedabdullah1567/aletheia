import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:share_plus/share_plus.dart';

Future<void> backupHiveDatabase(BuildContext context) async {
  try {
    // 1. Get the exact path directly from the open Hive box
    final box = Hive.box('MyBox');
    final String? dbPath = box.path;

    if (dbPath != null && await File(dbPath).exists()) {
      // 2. Trigger the native Share dialog
      await Share.shareXFiles([XFile(dbPath)], text: 'MyBox_Backup');

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Opening share menu...')));
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Database file not found at: $dbPath')),
        );
      }
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Backup Error: $e')));
    }
  }
}
