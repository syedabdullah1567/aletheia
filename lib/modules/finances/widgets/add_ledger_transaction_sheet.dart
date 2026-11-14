import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/finance_controller.dart';
import '../models/ledger_transaction.dart';
import '../models/person.dart';
import '../utils/finance_formatters.dart';

/// Opens the sheet.
/// - Nothing extra: add a transaction, choosing/typing a person.
/// - [person]: add a transaction with that person (name locked).
/// - [existing]: edit (and optionally delete) that transaction.
Future<void> showLedgerTransactionSheet(
  BuildContext context,
  FinanceController controller, {
  Person? person,
  LedgerTransaction? existing,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => LedgerTransactionSheet(
      controller: controller,
      person: person,
      existing: existing,
    ),
  );
}

class LedgerTransactionSheet extends StatefulWidget {
  final FinanceController controller;
  final Person? person;
  final LedgerTransaction? existing;

  const LedgerTransactionSheet({
    super.key,
    required this.controller,
    this.person,
    this.existing,
  });

  @override
  State<LedgerTransactionSheet> createState() => _LedgerTransactionSheetState();
}

class _LedgerTransactionSheetState extends State<LedgerTransactionSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _noteCtrl;
  late LedgerType _type;
  late DateTime _timestamp;
  Person? _lockedPerson;
  String? _error;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _lockedPerson = widget.person ??
        (e == null ? null : widget.controller.personById(e.personId));

    _nameCtrl = TextEditingController(text: _lockedPerson?.name ?? '');
    _amountCtrl = TextEditingController(
      text: e == null
          ? ''
          : (e.amount == e.amount.roundToDouble()
              ? e.amount.toStringAsFixed(0)
              : e.amount.toString()),
    );
    _noteCtrl = TextEditingController(text: e?.note ?? '');
    _type = e?.type ?? LedgerType.borrowed;
    _timestamp = e?.timestamp ?? DateTime.now();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _timestamp.isAfter(now) ? now : _timestamp,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _timestamp = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _timestamp.hour,
          _timestamp.minute,
        );
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_timestamp),
    );
    if (picked != null) {
      setState(() {
        _timestamp = DateTime(
          _timestamp.year,
          _timestamp.month,
          _timestamp.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  void _save() {
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', ''));
    final name = _nameCtrl.text.trim();

    if (_lockedPerson == null && name.isEmpty) {
      setState(() => _error = 'Who is this with?');
      return;
    }
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter an amount greater than 0');
      return;
    }

    if (_isEditing) {
      widget.controller.updateTransaction(
        widget.existing!.copyWith(
          amount: amount,
          type: _type,
          note: _noteCtrl.text.trim(),
          timestamp: _timestamp,
        ),
      );
    } else {
      // addPerson reuses an existing person with the same name.
      final person = _lockedPerson ?? widget.controller.addPerson(name);
      widget.controller.addTransaction(
        personId: person.id,
        amount: amount,
        type: _type,
        note: _noteCtrl.text.trim(),
        timestamp: _timestamp,
      );
    }
    Navigator.pop(context);
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this transaction?'),
        content: const Text('This can\'t be undone.'),
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
    if (confirmed == true && mounted) {
      widget.controller.deleteTransaction(widget.existing!.id);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final typed = _nameCtrl.text.trim().toLowerCase();
    final suggestions = _lockedPerson != null
        ? <Person>[]
        : widget.controller.people
            .where((p) =>
                p.name.toLowerCase() != typed &&
                (typed.isEmpty || p.name.toLowerCase().contains(typed)))
            .take(8)
            .toList();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _isEditing ? 'Edit transaction' : 'Add transaction',
                    style: textTheme.titleLarge,
                  ),
                ),
                if (_isEditing)
                  IconButton(
                    onPressed: _confirmDelete,
                    icon: const Icon(Icons.delete_outline_rounded),
                    tooltip: 'Delete',
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<LedgerType>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: LedgerType.borrowed,
                    label: Text('I borrowed'),
                    icon: Icon(Icons.south_west_rounded),
                  ),
                  ButtonSegment(
                    value: LedgerType.gave,
                    label: Text('I gave'),
                    icon: Icon(Icons.north_east_rounded),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (s) => setState(() => _type = s.first),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _type == LedgerType.borrowed
                  ? 'Money came to you: a loan from them, or them paying you back.'
                  : 'Money went to them: a loan to them, or you paying them back.',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              enabled: _lockedPerson == null,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Person',
                border: OutlineInputBorder(),
              ),
            ),
            if (suggestions.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final p in suggestions)
                    ActionChip(
                      label: Text(p.name),
                      onPressed: () => setState(() => _nameCtrl.text = p.name),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText:
                    kCurrencySymbol.isEmpty ? null : '$kCurrencySymbol ',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                hintText: 'e.g. Lunch, returned half',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today_rounded, size: 18),
                    label: Text(formatDate(_timestamp)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.schedule_rounded, size: 18),
                    label: Text(
                      TimeOfDay.fromDateTime(_timestamp).format(context),
                    ),
                  ),
                ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: Text(_isEditing ? 'Save changes' : 'Add transaction'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
