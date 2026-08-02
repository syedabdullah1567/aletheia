import 'package:flutter/material.dart';

class SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const SummaryChip({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon, color: colors.primary),

          const SizedBox(height: 8),

          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),

          Text(label, style: TextStyle(color: colors.onSurfaceVariant)),
        ],
      ),
    );
  }
}
