import 'package:aletheia/pages/login_page.dart';
import 'package:aletheia/pages/welcome_page.dart';
import 'package:aletheia/pages/ai/ai_test.dart';
import 'pages/module_selector.dart';
import 'pages/bellylog/homepage_bellylog.dart';
import 'pages/bellylog/log_bowel_movements.dart';
import 'pages/bellylog/log_daily_checkins.dart';
import 'pages/bellylog/log_meals.dart';
import 'pages/bellylog/log_symptoms.dart';
import 'pages/bellylog/view_bowel_movements.dart';
import 'pages/bellylog/view_daily_checkins.dart';
import 'pages/bellylog/view_meals.dart';
import 'pages/bellylog/view_symptoms.dart';
import '/pages/notifications.dart';
import '/utilities/value_notifier.dart';
import 'package:aletheia/pages/checkpoints/homepage_checkpoints.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// import 'package:dynamic_color/dynamic_color.dart';

void main() async {
  // Ensure bindings are initialized before calling async code
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // ignore: unused_local_variable
  var box = await Hive.openBox('MyBox');

  NotifyTasks().initNotification();
  NotifyTasks().requestAndroidPermissions();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Listen to your dark mode notifier here
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Aletheia',

          theme: ThemeData(
            useMaterial3: true,

            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.pink,
              brightness: Brightness.light,
            ),

            fontFamily: 'Roboto',

            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),

          darkTheme: ThemeData(
            useMaterial3: true,

            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.pink,
              brightness: Brightness.dark,
            ),

            fontFamily: 'Roboto',

            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),

          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,

          initialRoute: '/',

          routes: {
            '/': (context) => const WelcomePage(),
            '/login': (context) => const LoginPage(),
            '/homepage': (context) => const ModuleSelector(),

            '/checkpoints': (context) => const HomepageCheckpoints(),

            '/bellylog': (context) => const AppStartPage(),

            '/ai_insights_bellylog': (context) => const AITest(),

            '/log_meal': (context) => const LogMeal(),

            '/view_meals': (context) => const ViewMealLogs(),

            '/log_symptom': (context) => const LogSymptom(),

            '/view_symptoms': (context) => const ViewSymptomLogs(),

            '/log_bowel_movement': (context) => const LogBowelMovement(),

            '/view_bowel_movements': (context) => const ViewBowelMovementLogs(),

            '/log_daily_checkin': (context) => LogDailyCheckin(),

            '/view_daily_checkins': (context) => ViewDailyCheckins(),

            '/aitest': (context) => AITest(),
          },
        );
      },
    );
  }
}
