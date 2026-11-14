import 'package:aletheia/utilities/uniform_appbar.dart';
import 'package:flutter/material.dart';

import '../controllers/finance_controller.dart';
import '../utils/finance_colors.dart';
import '../widgets/add_ledger_transaction_sheet.dart';
import '../widgets/ledger_filter_chips.dart';
import '../widgets/person_balance_tile.dart';
import 'person_detail_page.dart';

class PeopleLedgerPage extends StatefulWidget {
  final FinanceController controller;

  const PeopleLedgerPage({super.key, required this.controller});

  @override
  State<PeopleLedgerPage> createState() => _PeopleLedgerPageState();
}

class _PeopleLedgerPageState extends State<PeopleLedgerPage> {
  LedgerFilter _filter = LedgerFilter.all;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final red = financeRed(context);
    final green = financeGreen(context);

    return Scaffold(
      appBar: UniformAppbar(
        leadIcon: const Icon(Icons.arrow_back_rounded),
        titleText: "Owed & Lent",
        onPress: () => Navigator.pop(context),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            showLedgerTransactionSheet(context, widget.controller),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add transaction'),
      ),
      body: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          final everyone = widget.controller.people;
          final balances = widget.controller.balances(filter: _filter);

          String emptyText;
          IconData emptyIcon;
          if (everyone.isEmpty) {
            emptyText = 'No one yet. Add a transaction to get started.';
            emptyIcon = Icons.group_outlined;
          } else if (_filter == LedgerFilter.iOwe) {
            emptyText = 'You don\'t owe anyone right now';
            emptyIcon = Icons.celebration_outlined;
          } else {
            emptyText = 'No one owes you right now';
            emptyIcon = Icons.hourglass_empty_rounded;
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              LedgerFilterChips(
                selected: _filter,
                onChanged: (f) => setState(() => _filter = f),
                iOweTotal: widget.controller.totalIOwe,
                owedToMeTotal: widget.controller.totalOwedToMe,
                red: red,
                green: green,
              ),
              const SizedBox(height: 16),
              if (balances.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Column(
                    children: [
                      Icon(
                        emptyIcon,
                        size: 48,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        emptyText,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                )
              else
                for (final b in balances)
                  PersonBalanceTile(
                    balance: b,
                    red: red,
                    green: green,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PersonDetailPage(
                          controller: widget.controller,
                          personId: b.person.id,
                        ),
                      ),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}
