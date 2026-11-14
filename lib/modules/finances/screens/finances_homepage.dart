import 'package:aletheia/utilities/uniform_appbar.dart';
import 'package:flutter/material.dart';

import '../controllers/finance_controller.dart';
import '../utils/finance_formatters.dart';
import '../widgets/finance_summary_card.dart';
import 'expenses_page.dart';
import 'income_page.dart';
import 'people_ledger_page.dart';

class FinancesHomepage extends StatefulWidget {
  const FinancesHomepage({Key? key}) : super(key: key);

  @override
  State<FinancesHomepage> createState() => _FinancesHomepageState();
}

class _FinancesHomepageState extends State<FinancesHomepage> {
  // One controller shared by every finances screen.
  late final FinanceController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FinanceController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _open(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final red = isDark ? Colors.red.shade300 : Colors.red.shade700;
    final green = isDark ? Colors.green.shade300 : Colors.green.shade700;

    return Scaffold(
      appBar: UniformAppbar(
        leadIcon: const Icon(Icons.arrow_back_rounded),
        titleText: "Finances",
        onPress: () => Navigator.pop(context),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final now = DateTime.now();
          final earned = _controller.totalIncomeForMonth(now);
          final spent = _controller.totalExpensesForMonth(now);
          final iOwe = _controller.totalIOwe;
          final owedToMe = _controller.totalOwedToMe;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  formatMonth(now),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
              FinanceSummaryCard(
                title: 'Money Earned',
                icon: Icons.south_west_rounded,
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
                stats: [
                  FinanceStat(
                    label: 'You earned this month',
                    value: formatAmount(earned),
                  ),
                ],
                onTap: () => _open(IncomePage(controller: _controller)),
              ),
              const SizedBox(height: 16),
              FinanceSummaryCard(
                title: 'Expenses',
                icon: Icons.north_east_rounded,
                backgroundColor: colorScheme.secondaryContainer,
                foregroundColor: colorScheme.onSecondaryContainer,
                stats: [
                  FinanceStat(
                    label: 'You spent this month',
                    value: formatAmount(spent),
                  ),
                ],
                onTap: () => _open(ExpensesPage(controller: _controller)),
              ),
              const SizedBox(height: 16),
              FinanceSummaryCard(
                title: 'Owed & Lent',
                icon: Icons.swap_horiz_rounded,
                backgroundColor: colorScheme.surfaceContainerHighest,
                foregroundColor: colorScheme.onSurface,
                stats: [
                  FinanceStat(
                    label: 'You owe',
                    value: formatAmount(iOwe),
                    valueColor: red,
                  ),
                  FinanceStat(
                    label: 'Owed to you',
                    value: formatAmount(owedToMe),
                    valueColor: green,
                  ),
                ],
                onTap: () => _open(PeopleLedgerPage(controller: _controller)),
              ),
            ],
          );
        },
      ),
    );
  }
}
