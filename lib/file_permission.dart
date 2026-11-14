import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

Future<void> requestManageExternalStorage() async {
  // Check if already granted
  if (await Permission.manageExternalStorage.isGranted) {
    print("All Files Access is already granted.");
    return;
  }

  try {
    // Open the specific "All files access" settings screen for this package
    final intent = AndroidIntent(
      action: 'android.settings.MANAGE_APP_ALL_FILES_ACCESS_PERMISSION',
      data: 'package:com.yourname.aletheia', // Replace with your actual application ID from build.gradle
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    await intent.launch();
  } catch (e) {
    // Fallback to standard app settings if intent fails
    print("Could not launch intent directly: $e");
    openAppSettings();
  }
}