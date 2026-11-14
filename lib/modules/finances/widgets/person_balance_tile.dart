import 'package:flutter/material.dart';

import '../models/person_balance.dart';
import '../utils/finance_formatters.dart';

class PersonBalanceTile extends StatelessWidget {
  final PersonBalance balance;
  final Color red;
  final Color green;
  final VoidCallback onTap;

  const PersonBalanceTile({
    Key? key,
    required this.balance,
    required this.red,
    required this.green,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final Color accent;
    final String status;
    if (balance.iOweThem) {
      accent = red;
      status = 'You owe';
    } else if (balance.theyOweMe) {
      accent = green;
      status = 'Owes you';
    } else {
      accent = colorScheme.onSurfaceVariant;
      status = 'Settled';
    }

    final name = balance.person.name;
    final initial = name.isEmpty ? '?' : name.characters.first.toUpperCase();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: colorScheme.surfaceContainerLow,
        leading: CircleAvatar(
          backgroundColor: colorScheme.secondaryContainer,
          child: Text(
            initial,
            style: TextStyle(
              color: colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          balance.lastActivity == null
              ? status
              : '$status · last ${formatDate(balance.lastActivity!)}',
        ),
        trailing: balance.isSettled
            ? Icon(Icons.check_circle_outline_rounded, color: accent)
            : Text(
                formatAmount(balance.absAmount),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.bold,
                    ),
              ),
      ),
    );
  }
}
