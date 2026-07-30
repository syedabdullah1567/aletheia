import 'package:aletheia/utilities/module_card.dart';
import 'package:aletheia/utilities/uniform_appbar.dart';
import 'package:flutter/material.dart';

class ModuleSelector extends StatefulWidget {
  const ModuleSelector({super.key});

  @override
  State<ModuleSelector> createState() => _ModuleSelectorState();
}

class _ModuleSelectorState extends State<ModuleSelector> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Custom squircle shape helper to keep code clean

    return Scaffold(
      appBar: UniformAppbar(
        leadIcon: Icon(Icons.logout_rounded),
        titleText: "Aletheia",
        onPress: () => Navigator.pushReplacementNamed(context, '/'),
      ),

      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Welcome back.',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Choose a space to continue your journey.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 20),

                ModuleCard(
                  title: 'Checkpoints',
                  subtitle: 'Reflect on the moments that shape you.',
                  icon: Icons.checklist_outlined,
                  height: 176,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primaryContainer,
                      colorScheme.secondaryContainer,
                    ],
                  ),
                  foregroundColor: colorScheme.onPrimaryContainer,
                  onTap: () {
                    Navigator.pushNamed(context, '/checkpoints');
                  },
                ),

                const SizedBox(height: 12),

                ModuleCard(
                  title: 'Bellylog',
                  subtitle: 'Understand the patterns behind your wellbeing.',
                  icon: Icons.local_hospital_outlined,
                  height: 176,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.surfaceContainerHigh,
                      colorScheme.surfaceContainerHighest,
                    ],
                  ),
                  foregroundColor: colorScheme.onSurface,
                  onTap: () {
                    Navigator.pushNamed(context, '/bellylog');
                  },
                ),

                const SizedBox(height: 12),

                ModuleCard(
                  title: 'Palimora',
                  subtitle: 'A deeper look at who you are becoming.',
                  icon: Icons.favorite_border_rounded,
                  height: 176,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.tertiaryContainer,
                      colorScheme.errorContainer,
                    ],
                  ),
                  foregroundColor: colorScheme.onTertiaryContainer,
                  onTap: () {
                    // Palimora Action
                  },
                ),

                const SizedBox(height: 15),

                Center(
                  child: Text(
                    'Your life, in different layers.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.65,
                      ),
                      fontStyle: FontStyle.italic,
                    ),
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
