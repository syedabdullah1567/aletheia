import 'package:aletheia/utilities/uniform_appbar.dart';
import 'package:flutter/material.dart';

import '../controllers/finance_controller.dart';
import '../models/expense_entry.dart';
import '../utils/expense_categories.dart';
import '../utils/finance_formatters.dart';
import '../widgets/add_expense_sheet.dart';
import '../widgets/category_breakdown.dart';

class ExpensesPage extends StatelessWidget {
  final FinanceController controller;

  const ExpensesPage({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final red = isDark ? Colors.red.shade300 : Colors.red.shade700;

    return Scaffold(
      appBar: UniformAppbar(
        leadIcon: const Icon(Icons.arrow_back_rounded),
        titleText: "Expenses",
        onPress: () => Navigator.pop(context),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showExpenseSheet(context, controller),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add expense'),
      ),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final now = DateTime.now();
          final entries = controller.expensesForMonth(now);
          final total = controller.totalExpensesForMonth(now);
          final categoryTotals = controller.categoryTotalsForMonth(now);
          final pastMonths = controller.monthsWithExpenses
              .where((m) => !isSameMonth(m, now))
              .toList();

          void edit(ExpenseEntry e) =>
              showExpenseSheet(context, controller, existing: e);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              // ── Current month summary ──
              Card(
                elevation: 0,
                margin: EdgeInsets.zero,
                color: colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        formatMonth(now),
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          formatAmount(total),
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: red,
                          ),
                        ),
                      ),
                      Text(
                        'Spent this month',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Where it went ──
              Text('Where it went', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              if (entries.isEmpty)
                _EmptyNote(
                  icon: Icons.receipt_long_outlined,
                  text: 'No expenses recorded this month',
                )
              else ...[
                CategoryBreakdown(totals: categoryTotals),
                const SizedBox(height: 24),
                Text('This month\'s expenses', style: textTheme.titleMedium),
                const SizedBox(height: 8),
                for (final e in entries)
                  ExpenseTile(entry: e, amountColor: red, onTap: () => edit(e)),
              ],
              const SizedBox(height: 24),

              // ── Past months ──
              Text('Past months', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              if (pastMonths.isEmpty)
                _EmptyNote(
                  icon: Icons.history_rounded,
                  text: 'Previous months will show up here',
                )
              else
                for (final month in pastMonths)
                  _PastMonthCard(
                    month: month,
                    controller: controller,
                    amountColor: red,
                    onEdit: edit,
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyNote extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EmptyNote({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(text, style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }
}

class _PastMonthCard extends StatelessWidget {
  final DateTime month;
  final FinanceController controller;
  final Color amountColor;
  final void Function(ExpenseEntry) onEdit;

  const _PastMonthCard({
    required this.month,
    required this.controller,
    required this.amountColor,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final entries = controller.expensesForMonth(month);
    final total = controller.totalExpensesForMonth(month);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: colorScheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        title: Text(formatMonth(month)),
        subtitle: Text('${formatAmount(total)} spent · ${entries.length} '
            '${entries.length == 1 ? 'expense' : 'expenses'}'),
        children: [
          CategoryBreakdown(totals: controller.categoryTotalsForMonth(month)),
          const Divider(height: 24),
          for (final e in entries)
            ExpenseTile(
              entry: e,
              amountColor: amountColor,
              tileColor: Colors.transparent,
              onTap: () => onEdit(e),
            ),
        ],
      ),
    );
  }
}

class ExpenseTile extends StatelessWidget {
  final ExpenseEntry entry;
  final Color amountColor;
  final Color? tileColor;
  final VoidCallback onTap;

  const ExpenseTile({
    Key? key,
    required this.entry,
    required this.amountColor,
    required this.onTap,
    this.tileColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasNote = entry.note.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: tileColor ?? colorScheme.surfaceContainerLow,
        leading: CircleAvatar(
          backgroundColor: colorScheme.secondaryContainer,
          child: Icon(
            iconForCategory(entry.category),
            color: colorScheme.onSecondaryContainer,
            size: 20,
          ),
        ),
        title: Text(
          hasNote ? entry.note : entry.category,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          hasNote
              ? '${entry.category} · ${formatDate(entry.date)}'
              : formatDate(entry.date),
        ),
        trailing: Text(
          '-${formatAmount(entry.amount)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: amountColor,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}
