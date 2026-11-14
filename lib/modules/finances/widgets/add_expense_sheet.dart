import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/finance_controller.dart';
import '../models/expense_entry.dart';
import '../utils/expense_categories.dart';
import '../utils/finance_formatters.dart';

/// Opens the add sheet, or the edit sheet when [existing] is given.
Future<void> showExpenseSheet(
  BuildContext context,
  FinanceController controller, {
  ExpenseEntry? existing,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => ExpenseSheet(controller: controller, existing: existing),
  );
}

class ExpenseSheet extends StatefulWidget {
  final FinanceController controller;
  final ExpenseEntry? existing;

  const ExpenseSheet({Key? key, required this.controller, this.existing})
      : super(key: key);

  @override
  State<ExpenseSheet> createState() => _ExpenseSheetState();
}

class _ExpenseSheetState extends State<ExpenseSheet> {
  late final TextEditingController _amountCtrl;
  late final TextEditingController _noteCtrl;
  late DateTime _date;
  String? _category;
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
    _noteCtrl = TextEditingController(text: e?.note ?? '');
    _date = e?.date ?? DateTime.now();
    _category = e?.category;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
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

    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter an amount greater than 0');
      return;
    }
    if (_category == null) {
      setState(() => _error = 'Pick a category');
      return;
    }

    if (_isEditing) {
      widget.controller.updateExpense(
        widget.existing!.copyWith(
          amount: amount,
          category: _category,
          note: _noteCtrl.text.trim(),
          date: _date,
        ),
      );
    } else {
      widget.controller.addExpense(
        amount: amount,
        category: _category!,
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
        title: const Text('Delete this expense?'),
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
      widget.controller.deleteExpense(widget.existing!.id);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // If an old entry has a category that's no longer in the list,
    // still show it so it stays selectable.
    final categories = [...kExpenseCategories];
    if (_category != null &&
        !categories.any((c) => c.name.toLowerCase() == _category!.toLowerCase())) {
      categories.add(ExpenseCategory(_category!, iconForCategory(_category!)));
    }

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
                    _isEditing ? 'Edit expense' : 'Add expense',
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
              controller: _noteCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'What did you spend it on?',
                hintText: 'e.g. Lunch with friends',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text('Category', style: textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final c in categories)
                  ChoiceChip(
                    avatar: Icon(c.icon, size: 18),
                    label: Text(c.name),
                    showCheckmark: false,
                    selected: _category?.toLowerCase() == c.name.toLowerCase(),
                    onSelected: (_) => setState(() => _category = c.name),
                  ),
              ],
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
                child: Text(_isEditing ? 'Save changes' : 'Add expense'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
