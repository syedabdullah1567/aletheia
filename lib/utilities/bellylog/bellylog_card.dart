import 'package:flutter/material.dart';

class BellyLogCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const BellyLogCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: colors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: colors.primary),
                  ),
                ),

                const Spacer(),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Container(
                      width: 26,
                      height: 3,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),

                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: colors.onSurfaceVariant,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
