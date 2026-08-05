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
    if (_myBox.get('HASLOGGED') == null) {
      db.createInitialData(0);
    } else {
      db.loadData(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UniformAppbar(
        leadIcon: const Icon(Icons.arrow_back_rounded),
        titleText: 'Palimora',
        onPress: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // Protects against overflow on smaller phones
          padding: const EdgeInsets.fromLTRB(60, 20, 60, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 100),

              // Collection IF + Spread operator for multiple widgets
              if (!db.hasLogged) ...[
                SizedBox(
                  height: 150,
                  child: HomepagesCard(
                    icon: Icons.accessibility_new_rounded,
                    title: 'Start Daily Log',
                    onTap: () async {
                      await Navigator.pushNamed(context, '/palimora_daily_log');
                      setState(() {
                        db.loadData(0);
                      });
                    },
                  ),
                ),
                const SizedBox(height: 50),
              ],

              SizedBox(
                height: 150,
                child: HomepagesCard(
                  icon: Icons.text_snippet_rounded,
                  title: 'Enter a journal entry',
                  onTap: () => Navigator.pushNamed(context, '/journal_entry'),
                ),
              ),
              const SizedBox(height: 50),

              SizedBox(
                height: 150,
                child: HomepagesCard(
                  icon: Icons.analytics,
                  title: 'View Dashboard',
                  onTap: () =>
                      Navigator.pushNamed(context, '/palimora_dashboard'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
