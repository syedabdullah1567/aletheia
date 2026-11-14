import 'package:aletheia/utilities/uniform_appbar.dart';
import 'package:flutter/material.dart';

import '../controllers/finance_controller.dart';
import '../models/ledger_transaction.dart';
import '../models/person.dart';
import '../models/person_balance.dart';
import '../utils/finance_colors.dart';
import '../utils/finance_formatters.dart';
import '../widgets/add_ledger_transaction_sheet.dart';

class PersonDetailPage extends StatelessWidget {
  final FinanceController controller;
  final String personId;

  const PersonDetailPage({
    Key? key,
    required this.controller,
    required this.personId,
  }) : super(key: key);

  Future<void> _rename(BuildContext context, Person person) async {
    final newName = await showDialog<String>(
      context: context,
      builder: (_) => _RenameDialog(initialName: person.name),
    );
    if (newName == null || newName == person.name) return;

    final taken = controller.people.any(
      (p) => p.id != person.id && p.name.toLowerCase() == newName.toLowerCase(),
    );
    if (taken) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Someone with that name already exists')),
        );
      }
      return;
    }
    controller.renamePerson(person.id, newName);
  }

  Future<void> _delete(BuildContext context, Person person, int count) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${person.name}?'),
        content: Text(
          count == 0
              ? 'This can\'t be undone.'
              : 'This also deletes all $count transaction'
                  '${count == 1 ? '' : 's'} with them. This can\'t be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      Navigator.pop(context);
      controller.deletePerson(person.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final person = controller.personById(personId);

        // Person was deleted while this page was still on screen.
        if (person == null) {
          return const Scaffold(body: SizedBox.shrink());
        }

        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;
        final red = financeRed(context);
        final green = financeGreen(context);

        final txns = controller.transactionsForPerson(personId); // newest first
        final balance = PersonBalance(
          person: person,
          balance: controller.balanceFor(personId),
        );

        // Running balance after each transaction (oldest -> newest).
        final runningAfter = <String, double>{};
        var running = 0.0;
        for (final t in txns.reversed) {
          running += t.signedAmount;
          runningAfter[t.id] = running;
        }

        final totalGave = txns
            .where((t) => t.type == LedgerType.gave)
            .fold(0.0, (s, t) => s + t.amount);
        final totalBorrowed = txns
            .where((t) => t.type == LedgerType.borrowed)
            .fold(0.0, (s, t) => s + t.amount);

        final Color accent;
        final String statusText;
        if (balance.iOweThem) {
          accent = red;
          statusText = 'You owe ${person.name}';
        } else if (balance.theyOweMe) {
          accent = green;
          statusText = '${person.name} owes you';
        } else {
          accent = colorScheme.onSurfaceVariant;
          statusText = 'All settled';
        }

        return Scaffold(
          appBar: UniformAppbar(
            leadIcon: const Icon(Icons.arrow_back_rounded),
            titleText: person.name,
            onPress: () => Navigator.pop(context),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => showLedgerTransactionSheet(
              context,
              controller,
              person: person,
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add transaction'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              // ── Balance header ──
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
                        statusText,
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      balance.isSettled
                          ? Icon(
                              Icons.check_circle_outline_rounded,
                              size: 40,
                              color: accent,
                            )
                          : FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                formatAmount(balance.absAmount),
                                style: textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: accent,
                                ),
                              ),
                            ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _MiniStat(
                              label: 'Total you gave',
                              value: formatAmount(totalGave),
                            ),
                          ),
                          Expanded(
                            child: _MiniStat(
                              label: 'Total you borrowed',
                              value: formatAmount(totalBorrowed),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton.icon(
                            onPressed: () => _rename(context, person),
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: const Text('Rename'),
                          ),
                          TextButton.icon(
                            onPressed: () =>
                                _delete(context, person, txns.length),
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                              color: colorScheme.error,
                            ),
                            label: Text(
                              'Delete',
                              style: TextStyle(color: colorScheme.error),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── History ──
              Text('History', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              if (txns.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      'No transactions yet',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                )
              else
                for (final t in txns)
                  _TransactionTile(
                    transaction: t,
                    balanceAfter: runningAfter[t.id] ?? 0,
                    red: red,
                    green: green,
                    onTap: () => showLedgerTransactionSheet(
                      context,
                      controller,
                      existing: t,
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final LedgerTransaction transaction;
  final double balanceAfter;
  final Color red;
  final Color green;
  final VoidCallback onTap;

  const _TransactionTile({
    required this.transaction,
    required this.balanceAfter,
    required this.red,
    required this.green,
    required this.onTap,
  });

  String _balanceText() {
    if (balanceAfter.abs() < 0.005) return 'Settled';
    return balanceAfter > 0
        ? 'They owe ${formatAmount(balanceAfter)}'
        : 'You owe ${formatAmount(balanceAfter.abs())}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // gave -> they owe me more (green). borrowed -> I owe more (red).
    final isGave = transaction.type == LedgerType.gave;
    final accent = isGave ? green : red;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        isThreeLine: transaction.note.isNotEmpty,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: colorScheme.surfaceContainerLow,
        leading: CircleAvatar(
          backgroundColor: accent.withOpacity(0.18),
          child: Icon(
            isGave ? Icons.north_east_rounded : Icons.south_west_rounded,
            color: accent,
            size: 20,
          ),
        ),
        title: Text(isGave ? 'I gave' : 'I borrowed'),
        subtitle: Text(
          transaction.note.isEmpty
              ? formatDateTime(transaction.timestamp)
              : '${transaction.note}\n${formatDateTime(transaction.timestamp)}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatAmount(transaction.amount),
              style: textTheme.titleMedium?.copyWith(
                color: accent,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _balanceText(),
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RenameDialog extends StatefulWidget {
  final String initialName;

  const _RenameDialog({required this.initialName});

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _ctrl.text.trim();
    Navigator.pop(context, name.isEmpty ? null : name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rename'),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        onSubmitted: (_) => _submit(),
        decoration: const InputDecoration(border: OutlineInputBorder()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}
