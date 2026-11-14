import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/finance_controller.dart';
import '../models/income_entry.dart';
import '../utils/finance_formatters.dart';

/// Quick-pick suggestions for the source field. Edit freely.
const List<String> kIncomeSources = [
  'Pocket money',
  'Gift',
  'Salary',
  'Freelance',
  'Refund',
  'Other',
];

/// Opens the add sheet, or the edit sheet when [existing] is given.
Future<void> showIncomeSheet(
  BuildContext context,
  FinanceController controller, {
  IncomeEntry? existing,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => IncomeSheet(controller: controller, existing: existing),
  );
}

class IncomeSheet extends StatefulWidget {
  final FinanceController controller;
  final IncomeEntry? existing;

  const IncomeSheet({Key? key, required this.controller, this.existing})
      : super(key: key);

  @override
  State<IncomeSheet> createState() => _IncomeSheetState();
}

class _IncomeSheetState extends State<IncomeSheet> {
  late final TextEditingController _amountCtrl;
  late final TextEditingController _sourceCtrl;
  late final TextEditingController _noteCtrl;
  late DateTime _date;
  String? _error;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _amountCtrl = TextEditingController(
      text: e == null
          ? ''
          : (e.amount == e.amount.roundToDouble()
              ? e.amount.toStringAsFixed(0)
              : e.amount.toString()),
    );
    _sourceCtrl = TextEditingController(text: e?.source ?? '');
    _noteCtrl = TextEditingController(text: e?.note ?? '');
    _date = e?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _sourceCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isAfter(now) ? now : _date,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (picked != null) {
      // Keep the original time-of-day so same-day entries stay ordered.
      setState(() {
        _date = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _date.hour,
          _date.minute,
        );
      });
    }
  }

  void _save() {
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', ''));
    final source = _sourceCtrl.text.trim();

    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter an amount greater than 0');
      return;
    }
    if (source.isEmpty) {
      setState(() => _error = 'Where did this money come from?');
      return;
    }

    if (_isEditing) {
      widget.controller.updateIncome(
        widget.existing!.copyWith(
          amount: amount,
          source: source,
          note: _noteCtrl.text.trim(),
          date: _date,
        ),
      );
    } else {
      widget.controller.addIncome(
        amount: amount,
        source: source,
        note: _noteCtrl.text.trim(),
        date: _date,
      );
    }
    Navigator.pop(context);
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this entry?'),
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
      widget.controller.deleteIncome(widget.existing!.id);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final typedSource = _sourceCtrl.text.trim().toLowerCase();

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
                    _isEditing ? 'Edit income' : 'Add income',
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
            TextField(
              controller: _amountCtrl,
              autofocus: !_isEditing,
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
              controller: _sourceCtrl,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Source',
                hintText: 'e.g. Gift, Pocket money',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final s in kIncomeSources)
                  ChoiceChip(
                    label: Text(s),
                    selected: typedSource == s.toLowerCase(),
                    onSelected: (_) => setState(() => _sourceCtrl.text = s),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today_rounded, size: 18),
              label: Text(formatDate(_date)),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: Text(_isEditing ? 'Save changes' : 'Add income'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
