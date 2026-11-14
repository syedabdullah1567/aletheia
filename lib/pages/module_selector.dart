import 'package:aletheia/backup_hive.dart';
import 'package:aletheia/restore_hive.dart';
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

    return Scaffold(
      appBar: UniformAppbar(
        leadIcon: const Icon(Icons.logout_rounded),
        titleText: "Aletheia",
        onPress: () => Navigator.pushReplacementNamed(context, '/'),
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return FractionallySizedBox(
              widthFactor: constraints.maxWidth > 500 ? 0.7 : 1,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Text(
                        'Your journey awaits you.',
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
                        subtitle:
                            'Understand the patterns behind your wellbeing.',
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
                          Navigator.pushNamed(context, '/palimora_homepage');
                        },
                      ),

                      const SizedBox(height: 12),

                      ModuleCard(
                        title: 'Finances',
                        subtitle: 'Track your resources and shape your future.',
                        icon: Icons.account_balance_wallet_outlined,
                        height: 176,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colorScheme.secondaryContainer,
                            colorScheme.tertiaryContainer,
                          ],
                        ),
                        foregroundColor: colorScheme.onSecondaryContainer,
                        onTap: () {
                          Navigator.pushNamed(context, '/finances_homepage');
                        },
                      ),

                      const SizedBox(height: 12),

                      ModuleCard(
                        title: 'Notes',
                        subtitle:
                            'Capture fleeting thoughts and quiet ideas.',
                        icon: Icons.edit_note_rounded,
                        height: 176,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colorScheme.primaryContainer,
                            colorScheme.surfaceContainerHighest,
                          ],
                        ),
                        foregroundColor: colorScheme.onPrimaryContainer,
                        onTap: () {
                          Navigator.pushNamed(context, '');
                        },
                      ),

                      const SizedBox(height: 15),

                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Wrap(
                            alignment: WrapAlignment.spaceEvenly,
                            spacing: 16,
                            runSpacing: 12,
                            children: [
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor:
                                      colorScheme.surfaceContainerHighest,
                                  foregroundColor: colorScheme.onSurface,
                                  elevation: 2,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () => backupHiveDatabase(context),
                                child: const Text('Backup Data'),
                              ),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor:
                                      colorScheme.surfaceContainerHighest,
                                  foregroundColor: colorScheme.onSurface,
                                  elevation: 2,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () => restoreHiveDatabase(context),
                                child: const Text('Restore Data'),
                              ),
                            ],
                          ),
                        ),
                      ),

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
            );
          },
        ),
      ),
    );
  }
}