import 'package:aletheia/data/palimora_database.dart';
import 'package:aletheia/utilities/homepages_card.dart';
import 'package:aletheia/utilities/uniform_appbar.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class PalimoraHomepage extends StatefulWidget {
  const PalimoraHomepage({super.key});

  @override
  State<PalimoraHomepage> createState() => _PalimoraHomepageState();
}

class _PalimoraHomepageState extends State<PalimoraHomepage> {
  final _myBox = Hive.box('MyBox');
  final PalimoraDatabase db = PalimoraDatabase();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: UniformAppbar(
        leadIcon: const Icon(Icons.arrow_back_rounded),
        titleText: 'Palimora',
        onPress: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // Protects against overflow on smaller phones
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //const SizedBox(height: 100),

              // Collection IF + Spread operator for multiple widgets
              if (!db.hasLogged) ...[
                SizedBox(
                  height: 140,
                  child: HomepagesCard(
                    icon: Icons.accessibility_new_rounded,
                    title: 'Start Daily Log',
                    onTap: () async {
                      // Wait for user to finish or leave the logging flow
                      final completed = await Navigator.pushNamed(
                        context,
                        '/palimora_daily_log',
                      );
                      // Rebuild Homepage - db.hasLogged automatically evaluates to true!
                      if (completed == true || db.hasLogged) setState(() {});
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],

              SizedBox(
                height: 140,
                child: HomepagesCard(
                  icon: Icons.analytics,
                  title: 'View Daily Log',
                  onTap: () =>
                      Navigator.pushNamed(context, '/palimora_dashboard'),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 140,
                child: HomepagesCard(
                  icon: Icons.text_snippet_rounded,
                  title: 'Enter a journal entry',
                  onTap: () => Navigator.pushNamed(context, '/journal_entry'),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 140,
                child: HomepagesCard(
                  icon: Icons.analytics,
                  title: 'View Journals',
                  onTap: () =>
                      Navigator.pushNamed(context, '/view_journal_entries'),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 140,
                child: HomepagesCard(
                  icon: Icons.analytics,
                  title: 'Get Palimora Insights',
                  onTap: () =>
                      Navigator.pushNamed(context, '/get_palimora_insight'),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Discover the pieces that form you.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.65),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
