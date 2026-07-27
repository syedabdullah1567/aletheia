import 'package:aletheia/utilities/dark_mode_switcher.dart';
import 'package:flutter/material.dart';

class AppStartPage extends StatefulWidget {
  const AppStartPage({super.key});

  @override
  State<AppStartPage> createState() => _AppStartPageState();
}

class _AppStartPageState extends State<AppStartPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [DarkModeSwitcher()],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'BellyLog',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                  letterSpacing: 1.2,
                ),
              ),

              // 1. Log Meal
              _buildMenuTile(
                context,
                icon: Icons.restaurant,
                label: 'Log Meal',
                onTap: () {
                  Navigator.pushNamed(context, '/log_meal');
                },
              ),

              // 2. Log Symptom
              _buildMenuTile(
                context,
                icon: Icons.healing,
                label: 'Log Symptom',
                onTap: () {
                  Navigator.pushNamed(context, '/log_symptom');
                },
              ),

              // 3. Log Bathroom Visit
              _buildMenuTile(
                context,
                icon: Icons.wc,
                label: 'Log Bathroom Visit',
                onTap: () {
                  Navigator.pushNamed(context, '/log_bowel_movement');
                },
              ),

              // 4. Daily Check-in
              _buildMenuTile(
                context,
                icon: Icons.today,
                label: 'Daily Check-in',
                onTap: () {
                  Navigator.pushNamed(context, '/log_daily_checkin');
                },
              ),

              // 5. Dashboard
              _buildMenuTile(
                context,
                icon: Icons.dashboard,
                label: 'Go to Dashboard',
                isPrimary: true,
                onTap: () {
                  Navigator.pushNamed(context, '/dashboard');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to keep your build tree clean and beautiful
  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    // Highlight the dashboard option subtly using the primary color track
    final tileColor = isPrimary
        ? colorScheme.primary
        : colorScheme.secondaryContainer;
    final contentColor = isPrimary
        ? colorScheme.onPrimary
        : colorScheme.onSecondaryContainer;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ListTile(
        leading: Icon(icon, color: contentColor, size: 26),
        tileColor: tileColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: 14.0,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: contentColor,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
