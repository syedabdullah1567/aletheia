import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.secondaryContainer,

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surface,
              colorScheme.secondaryContainer,
              colorScheme.primaryContainer.withValues(alpha: 0.45),
            ],
          ),
        ),

        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 50),

                // Animated heart section
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 290,
                      height: 290,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primary.withValues(alpha: 0.08),
                      ),
                    ),

                    Container(
                      width: 230,
                      height: 230,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.surface.withValues(alpha: 0.65),
                      ),
                    ),

                    Column(
                      children: [
                        SizedBox(height: 20),
                        Lottie.asset(
                          'assets/lotties/Heart.json',
                          width: 250,
                          height: 250,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 50),

                const SizedBox(height: 34),

                // App name
                Text(
                  'Aletheia',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 12,
                    color: colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 14),

                // Subtitle
                Text(
                  'A space to understand yourself better.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),

                const Spacer(),

                // Login button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    icon: const Icon(Icons.login_rounded),
                    label: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/weekly_aletheia_insight');
                    },
                    icon: const Icon(Icons.chat),
                    label: const Text(
                      'Generate a weekly analysis of your life',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.secondaryContainer,
                      foregroundColor: colorScheme.onSecondaryContainer,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(
                          color: colorScheme.outline.withValues(alpha: 0.15),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  'Your personal space for reflection',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
