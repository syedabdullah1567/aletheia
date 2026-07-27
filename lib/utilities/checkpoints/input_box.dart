import 'buttons.dart';
import '../custom_date_time.dart';
import 'package:flutter/material.dart';

class InputBox extends StatefulWidget {
  final TextEditingController controller;
  final DateTime currentTime;
  final ValueChanged<DateTime> onSave;
  final VoidCallback onCancel;
  final int pageNum;

  const InputBox({
    super.key,
    required this.controller,
    required this.currentTime,
    required this.onSave,
    required this.onCancel,
    required this.pageNum,
  });

  @override
  State<InputBox> createState() => _InputBoxState();
}

class _InputBoxState extends State<InputBox> {
  late DateTime currentTime;

  @override
  void initState() {
    super.initState();
    currentTime = widget.currentTime;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bool isEditing = widget.controller.text.isNotEmpty;

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),

      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),

      title: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              isEditing ? Icons.edit_rounded : Icons.add_task_rounded,
              color: colorScheme.onPrimaryContainer,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              isEditing ? 'Edit checkpoint' : 'New checkpoint',

              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),

      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),

      content: SizedBox(
        width: 360,

        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            Text(
              widget.pageNum == 0
                  ? 'What would you like to accomplish today?'
                  : 'What are you working towards?',

              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 18),

            TextField(
              controller: widget.controller,
              maxLines: 4,
              minLines: 2,
              autofocus: !isEditing,
              keyboardType: TextInputType.multiline,

              style: theme.textTheme.bodyLarge,

              decoration: InputDecoration(
                hintText: widget.pageNum == 0
                    ? 'Write a checkpoint...'
                    : 'Write something meaningful...',

                filled: true,

                fillColor: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),

                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 16, right: 8, bottom: 38),
                  child: Icon(Icons.notes_rounded),
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),

                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
              ),
            ),

            const SizedBox(height: 16),

            if (widget.pageNum == 0)
              TimePickerBanner(
                currentTime: currentTime,
                onTimeChanged: (newTime) {
                  setState(() {
                    currentTime = newTime;
                  });
                },
              )
            else
              DateTimePickerBanner(
                currentTime: currentTime,
                onTimeChanged: (newTime) {
                  setState(() {
                    currentTime = newTime;
                  });
                },
              ),
          ],
        ),
      ),

      actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),

      actions: [
        MyButton(text: 'Cancel', onPressed: widget.onCancel, isPrimary: false),

        const SizedBox(width: 8),

        MyButton(
          text: isEditing ? 'Save changes' : 'Add checkpoint',
          onPressed: () => widget.onSave(currentTime),
          isPrimary: true,
        ),
      ],
    );
  }
}
