import 'package:flutter/material.dart';

import '../../utilities/dark_mode_switcher.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'BellyLog Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
        centerTitle: true,
        actions: [DarkModeSwitcher()],
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.analytics_outlined,
                  size: 64,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Welcome to BellyLog!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your data and track your progress.',
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),

                ListTile(
                  leading: Icon(Icons.restaurant, color: colorScheme.primary),
                  title: Text(
                    'View Meal Logs',
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/view_meal_logs');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.healing, color: colorScheme.primary),
                  title: Text(
                    'View Symptom Logs',
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/view_symptom_logs');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.wc, color: colorScheme.primary),
                  title: Text(
                    'View Bathroom Visits',
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/view_bowel_movement_logs');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.today, color: colorScheme.primary),
                  title: Text(
                    'View Daily Check-ins',
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/view_daily_checkins');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
