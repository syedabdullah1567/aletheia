import 'package:aletheia/data/bellylog_database.dart';
import 'package:aletheia/utilities/bellylog/belly_summary_card.dart';
import 'package:aletheia/utilities/bellylog/bellylog_card.dart';
import 'package:aletheia/utilities/bellylog/insights_card.dart';
import 'package:aletheia/utilities/uniform_appbar.dart';
import 'package:flutter/material.dart';

class AppStartPage extends StatefulWidget {
  const AppStartPage({super.key});

  @override
  State<AppStartPage> createState() => _AppStartPageState();
}

class _AppStartPageState extends State<AppStartPage> {
  late BellyLogDatabase db;

  @override
  void initState() {
    super.initState();

    db = BellyLogDatabase();
    db.seedTest7DayData();
    //db.loadData();
  }

  Future<void> _openPage(BuildContext context, String route) async {
    await Navigator.pushNamed(context, route);

    db.loadData();

    if (mounted) {
      setState(() {});
    }
  }

  int _countEntriesToday(Map<String, dynamic> log) {
    final now = DateTime.now();

    return log.keys.where((key) {
      final entryDate = DateTime.tryParse(key);
      if (entryDate == null) return false;

      return entryDate.year == now.year &&
          entryDate.month == now.month &&
          entryDate.day == now.day;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final db = BellyLogDatabase()..loadData();

    final mealsToday = _countEntriesToday(db.mealLog);
    final symptomsToday = _countEntriesToday(db.symptomLog);
    final bathroomVisitsToday = _countEntriesToday(db.bowelLog);

    return Scaffold(
      appBar: UniformAppbar(
        leadIcon: Icon(Icons.arrow_back_rounded),
        titleText: "Bellylog",
        onPress: () => Navigator.pop(context),
      ),

      body: SafeArea(
        child: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  BellySummaryCard(
                    mealsToday: mealsToday,
                    symptomsToday: symptomsToday,
                    bathroomVisitsToday: bathroomVisitsToday,
                  ),

                  const SizedBox(height: 24),
                ]),
              ),
            ),

            SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 40),
              sliver: SliverGrid(
                delegate: SliverChildListDelegate([
                  BellyLogCard(
                    icon: Icons.restaurant_rounded,
                    title: "Log Meal",
                    onTap: () => _openPage(context, '/log_meal'),
                  ),

                  BellyLogCard(
                    icon: Icons.menu_book_rounded,
                    title: "View Meals",

                    onTap: () => _openPage(context, '/view_meals'),
                  ),

                  BellyLogCard(
                    icon: Icons.monitor_heart_outlined,
                    title: "Log Symptoms",

                    onTap: () => _openPage(context, '/log_symptom'),
                  ),

                  BellyLogCard(
                    icon: Icons.analytics_outlined,
                    title: "View Symptoms",

                    onTap: () => _openPage(context, '/view_symptoms'),
                  ),

                  BellyLogCard(
                    icon: Icons.wc_rounded,
                    title: "Log Bathroom Visits",

                    onTap: () => _openPage(context, '/log_bowel_movement'),
                  ),

                  BellyLogCard(
                    icon: Icons.list_alt_rounded,
                    title: "View Bathroom Visits",

                    onTap: () => _openPage(context, '/view_bowel_movements'),
                  ),

                  BellyLogCard(
                    icon: Icons.today_rounded,
                    title: "Daily Check-in",

                    onTap: () => _openPage(context, '/log_daily_checkin'),
                  ),

                  BellyLogCard(
                    icon: Icons.calendar_month_rounded,
                    title: "View Check-ins",

                    onTap: () => _openPage(context, '/view_daily_checkins'),
                  ),
                ]),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.18,
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              sliver: SliverToBoxAdapter(
                child: InsightsCard(
                  onTap: () {
                    Navigator.pushNamed(context, "/ai_insights_bellylog");
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
