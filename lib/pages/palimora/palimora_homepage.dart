import 'package:aletheia/data/palimora_database.dart';
import 'package:aletheia/utilities/homepages_card.dart';
import 'package:aletheia/utilities/hero_widget.dart';
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
              // // --- 2 CARDS SIDE-BY-SIDE ---
              // SizedBox(
              //   height: 130,
              //   child: Row(
              //     children: [
              //       Expanded(
              //         child: HomepageCard(
              //           icon: Icons.analytics,
              //           title: 'Analytics',
              //           onTap: () {},
              //         ),
              //       ),
              //       const SizedBox(width: 12),
              //       Expanded(
              //         // child: HomepageCard(
              //         //   icon: Icons.abc,
              //         //   title: 'Hello',
              //         //   onTap: () {},
              //         // ),
              //         child: BellyLogCard(
              //           icon: Icons.analytics,
              //           title: 'Analytics',
              //           onTap: () {},
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              const SizedBox(height: 250),

              // --- 1 FULL-WIDTH CARD ---
              SizedBox(
                height: 150,
                child: BellyLogCard(
                  icon: Icons.accessibility_new_rounded,
                  title: 'Start Daily Log',
                  onTap: () =>
                      Navigator.pushNamed(context, '/palimora_daily_log'),
                ),
              ),

              const SizedBox(height: 100),
              SizedBox(
                height: 150,
                child: BellyLogCard(
                  icon: Icons.analytics,
                  title: 'View Dashboard',
                  onTap: () {},
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
