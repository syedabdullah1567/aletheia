import 'package:aletheia/utilities/uniform_appbar.dart';
import 'package:flutter/material.dart';

import '../controllers/finance_controller.dart';
import '../models/income_entry.dart';
import '../utils/finance_formatters.dart';
import '../widgets/add_income_sheet.dart';
import '../widgets/month_header.dart';

class IncomePage extends StatefulWidget {
  final FinanceController controller;

  const IncomePage({Key? key, required this.controller}) : super(key: key);

  @override
  State<IncomePage> createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    _month = monthStart(DateTime.now());
  }

  bool get _isCurrentMonth => isSameMonth(_month, DateTime.now());

  void _changeMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final green = isDark ? Colors.green.shade300 : Colors.green.shade700;

    return Scaffold(
      appBar: UniformAppbar(
        leadIcon: const Icon(Icons.arrow_back_rounded),
        titleText: "Money Earned",
        onPress: () => Navigator.pop(context),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showIncomeSheet(context, widget.controller),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add income'),
      ),
      body: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          final entries = widget.controller.incomeForMonth(_month);
          final total = widget.controller.totalIncomeForMonth(_month);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              MonthHeader(
                month: _month,
                totalLabel: 'Total earned',
                total: total,
                accentColor: green,
                onPrevious: () => _changeMonth(-1),
                onNext: _isCurrentMonth ? null : () => _changeMonth(1),
              ),
              const SizedBox(height: 16),
              if (entries.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Column(
                    children: [
                      Icon(
                        Icons.savings_outlined,
                        size: 48,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No income recorded for this month',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                )
              else
                for (final entry in entries)
                  _IncomeTile(
                    entry: entry,
                    amountColor: green,
                    onTap: () => showIncomeSheet(
                      context,
                      widget.controller,
                      existing: entry,
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _IncomeTile extends StatelessWidget {
  final IncomeEntry entry;
  final Color amountColor;
  final VoidCallback onTap;

  const _IncomeTile({
    required this.entry,
    required this.amountColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final subtitle = entry.note.isEmpty
        ? formatDate(entry.date)
        : '${formatDate(entry.date)} · ${entry.note}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: colorScheme.surfaceContainerLow,
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(
            Icons.south_west_rounded,
            color: colorScheme.onPrimaryContainer,
            size: 20,
          ),
        ),
        title: Text(entry.source),
        subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Text(
          '+${formatAmount(entry.amount)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: amountColor,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}
