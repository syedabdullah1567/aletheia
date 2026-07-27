import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class ToDoTile extends StatefulWidget {
  final bool taskCompleted;
  final Function(bool?)? onChanged;
  final String taskName;
  final Function(BuildContext)? deleteFunction;
  final VoidCallback? onTap;
  final DateTime dueTime;
  final int pageNum;

  const ToDoTile({
    super.key,
    required this.taskName,
    required this.dueTime,
    required this.taskCompleted,
    required this.onChanged,
    required this.deleteFunction,
    this.onTap,
    required this.pageNum,
  });

  @override
  State<ToDoTile> createState() => _ToDoTileState();
}

class _ToDoTileState extends State<ToDoTile> {
  Timer? _longPressTimer;

  @override
  void dispose() {
    _longPressTimer?.cancel();
    super.dispose();
  }

  void _startLongPressFeedback() {
    _longPressTimer?.cancel();

    _longPressTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        HapticFeedback.lightImpact();
      }
    });
  }

  void _cancelLongPressFeedback() {
    _longPressTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bool isOverdue =
        widget.dueTime.isBefore(DateTime.now()) && !widget.taskCompleted;

    final Color dueDateColor = isOverdue
        ? colorScheme.error
        : colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),

      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),

          children: [
            SlidableAction(
              onPressed: widget.deleteFunction,
              icon: Icons.delete_outline_rounded,
              label: 'Delete',

              backgroundColor: colorScheme.errorContainer,
              foregroundColor: colorScheme.onErrorContainer,

              borderRadius: BorderRadius.circular(22),
            ),
          ],
        ),

        child: Listener(
          onPointerDown: (_) => _startLongPressFeedback(),
          onPointerUp: (_) => _cancelLongPressFeedback(),
          onPointerCancel: (_) => _cancelLongPressFeedback(),

          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(22),

            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(22),

              child: Ink(
                padding: const EdgeInsets.fromLTRB(14, 14, 18, 14),

                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.55,
                  ),

                  borderRadius: BorderRadius.circular(22),

                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),

                child: Row(
                  children: [
                    Transform.scale(
                      scale: 1.15,

                      child: Checkbox(
                        value: widget.taskCompleted,
                        onChanged: widget.onChanged,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            widget.taskName,
                            softWrap: true,

                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,

                              color: widget.taskCompleted
                                  ? colorScheme.onSurfaceVariant
                                  : colorScheme.onSurface,

                              decoration: widget.taskCompleted
                                  ? TextDecoration.lineThrough
                                  : null,

                              decorationColor: colorScheme.onSurfaceVariant,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Row(
                            children: [
                              Icon(
                                widget.pageNum == 0
                                    ? Icons.schedule_rounded
                                    : Icons.calendar_today_rounded,

                                size: 15,

                                color: dueDateColor,
                              ),

                              const SizedBox(width: 5),

                              Flexible(
                                child: Text(
                                  widget.pageNum == 0
                                      ? DateFormat(
                                          'h:mm a',
                                        ).format(widget.dueTime)
                                      : DateFormat(
                                          'MMMM d, yyyy • h:mm a',
                                        ).format(widget.dueTime),

                                  overflow: TextOverflow.ellipsis,

                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: dueDateColor,

                                    fontWeight: isOverdue
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),

                              if (isOverdue) ...[
                                const SizedBox(width: 8),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),

                                  decoration: BoxDecoration(
                                    color: colorScheme.errorContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),

                                  child: Text(
                                    'Overdue',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onErrorContainer,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    Icon(
                      Icons.drag_indicator_rounded,
                      size: 22,
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
