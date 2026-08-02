import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final int pageId;
  final VoidCallback onAddTask;

  const EmptyState({super.key, required this.pageId, required this.onAddTask});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 70),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,

            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),

            child: Icon(
              pageId == 0 ? Icons.wb_sunny_outlined : Icons.flag,

              size: 42,

              color: colorScheme.onPrimaryContainer,
            ),
          ),

          const SizedBox(height: 24),

          Text(
            pageId == 0 ? 'Nothing planned yet.' : 'Your horizon is open.',

            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            pageId == 0
                ? 'Add a checkpoint for today.'
                : 'Add something you want to work towards.',

            textAlign: TextAlign.center,

            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 24),

          FilledButton.icon(
            onPressed: onAddTask,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add one'),
          ),
        ],
      ),
    );
  }
}
