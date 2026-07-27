import '../../data/todo_database.dart';
import '../../utilities/checkpoints/input_box.dart';
import '../../utilities/checkpoints/todo_tile.dart';
import '../notifications.dart';
import '../../utilities/dark_mode_switcher.dart';
import '../../utilities/checkpoints/progress_card.dart';
import '../../utilities/checkpoints/empty_state.dart';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class ToDoPage extends StatefulWidget {
  final int pageId;

  const ToDoPage({super.key, required this.pageId});

  @override
  State<ToDoPage> createState() => _ToDoPageState();
}

class _ToDoPageState extends State<ToDoPage> {
  final _myBox = Hive.box('MyBox');

  final ToDoDataBase db = ToDoDataBase();
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize daily tasks
    if (_myBox.get('TODOLIST') == null) {
      db.createInitialDaily();
      db.updateToDo();
    } else {
      db.loadToDo();
    }

    // Initialize long-term tasks
    if (_myBox.get('LONGTERM') == null) {
      db.createInitialLongTerm();
      db.updateLongTerm();
    } else {
      db.loadLongTerm();
    }

    _syncTasks();
  }

  void _syncTasks() {
    setState(() {
      db.loadToDo();
      db.loadLongTerm();
      db.moveLongtermToDaily();
    });
  }

  void checkBoxChanged(bool? value, int index) {
    if (widget.pageId == 0) {
      setState(() {
        db.todoList[index][1] = !db.todoList[index][1];
      });

      db.updateToDo();

      final int taskId = db.todoList[index][3];

      if (db.todoList[index][1] == false) {
        NotifyTasks().scheduleTodoNotification(
          id: taskId,
          title: 'You have a task pending',
          body: db.todoList[index][0],
          dueDate: db.todoList[index][2],
        );
      } else {
        NotifyTasks().cancelSingleNotification(taskId);
      }
    } else {
      setState(() {
        db.longTerm[index][1] = !db.longTerm[index][1];
      });

      db.updateLongTerm();

      final int taskId = db.longTerm[index][3];

      if (db.longTerm[index][1] == false) {
        NotifyTasks().scheduleTodoNotification(
          id: taskId,
          title: 'You have a long-term task pending',
          body: db.longTerm[index][0],
          dueDate: db.longTerm[index][2],
        );
      } else {
        NotifyTasks().cancelSingleNotification(taskId);
      }
    }
  }

  void createNewTask() {
    final DateTime freshCurrentTime = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      widget.pageId == 0 ? DateTime.now().day : DateTime.now().day + 1,
      23,
      59,
    );

    showDialog(
      context: context,
      builder: (context) {
        _controller.clear();

        return InputBox(
          controller: _controller,
          currentTime: freshCurrentTime,

          onSave: (selectedTime) {
            if (_controller.text.isNotEmpty) {
              final int uniqueId = DateTime.now().millisecondsSinceEpoch
                  .remainder(10000000);

              if (widget.pageId == 0) {
                setState(() {
                  db.todoList.add([
                    _controller.text,
                    false,
                    selectedTime,
                    uniqueId,
                  ]);
                });

                db.updateToDo();

                NotifyTasks().scheduleTodoNotification(
                  id: uniqueId,
                  title: 'You have a task pending',
                  body: _controller.text,
                  dueDate: selectedTime,
                );
              } else {
                setState(() {
                  db.longTerm.add([
                    _controller.text,
                    false,
                    selectedTime,
                    uniqueId,
                  ]);
                });

                db.updateLongTerm();

                NotifyTasks().scheduleTodoNotification(
                  id: uniqueId,
                  title: 'You have a long-term task pending',
                  body: _controller.text,
                  dueDate: selectedTime,
                );
              }

              Navigator.of(context).pop();
            }
          },

          onCancel: () {
            Navigator.of(context).pop();
          },

          pageNum: widget.pageId,
        );
      },
    );
  }

  void editTask(int index) {
    if (widget.pageId == 0) {
      _controller.text = db.todoList[index][0];
    } else {
      _controller.text = db.longTerm[index][0];
    }

    showDialog(
      context: context,
      builder: (context) {
        return InputBox(
          controller: _controller,

          currentTime: widget.pageId == 0
              ? db.todoList[index][2]
              : db.longTerm[index][2],

          onSave: (selectedTime) {
            if (_controller.text.isNotEmpty) {
              if (widget.pageId == 0) {
                final int taskId = db.todoList[index][3];

                setState(() {
                  db.todoList[index][0] = _controller.text;
                  db.todoList[index][2] = selectedTime;
                });

                db.updateToDo();

                NotifyTasks().scheduleTodoNotification(
                  id: taskId,
                  title: 'You have a task pending',
                  body: _controller.text,
                  dueDate: selectedTime,
                );
              } else {
                final int taskId = db.longTerm[index][3];

                setState(() {
                  db.longTerm[index][0] = _controller.text;
                  db.longTerm[index][2] = selectedTime;
                });

                db.updateLongTerm();

                NotifyTasks().scheduleTodoNotification(
                  id: taskId,
                  title: 'You have a long-term task pending',
                  body: _controller.text,
                  dueDate: selectedTime,
                );
              }

              Navigator.of(context).pop();
            }
          },

          onCancel: () {
            Navigator.of(context).pop();
          },

          pageNum: widget.pageId,
        );
      },
    );
  }

  void deleteTask(int index) {
    if (widget.pageId == 0) {
      final int taskId = db.todoList[index][3];

      setState(() {
        db.todoList.removeAt(index);
      });

      db.updateToDo();

      NotifyTasks().cancelSingleNotification(taskId);
    } else {
      final int taskId = db.longTerm[index][3];

      setState(() {
        db.longTerm.removeAt(index);
      });

      db.updateLongTerm();

      NotifyTasks().cancelSingleNotification(taskId);
    }
  }

  void reorderTasks(int oldIndex, int newIndex) {
    if (widget.pageId == 0) {
      setState(() {
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }

        final item = db.todoList.removeAt(oldIndex);
        db.todoList.insert(newIndex, item);
      });

      db.updateToDo();
    } else {
      setState(() {
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }

        final item = db.longTerm.removeAt(oldIndex);
        db.longTerm.insert(newIndex, item);
      });

      db.updateLongTerm();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final List currentTasks = widget.pageId == 0 ? db.todoList : db.longTerm;

    final int completedTasks = currentTasks
        .where((task) => task[1] == true)
        .length;

    final int totalTasks = currentTasks.length;

    final double progress = totalTasks == 0 ? 0 : completedTasks / totalTasks;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // HEADER
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 20, 12, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.pageId == 0 ? 'Today' : 'Long-term',
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.1,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            widget.pageId == 0
                                ? DateFormat(
                                    'EEEE, MMMM d',
                                  ).format(DateTime.now())
                                : 'The things you are working towards.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const DarkModeSwitcher(),
                  ],
                ),
              ),
            ),

            // Progress card
            if (widget.pageId == 0)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
                sliver: SliverToBoxAdapter(
                  child: ProgressCard(
                    completedTasks: completedTasks,
                    totalTasks: totalTasks,
                    progress: progress,
                  ),
                ),
              ),

            // ─────────────────────────────────────────────
            // TASK LIST
            // ─────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              sliver: SliverToBoxAdapter(
                child: currentTasks.isEmpty
                    ? EmptyState(
                        pageId: widget.pageId,
                        onAddTask: createNewTask,
                      )
                    : ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        buildDefaultDragHandles: false,
                        itemCount: currentTasks.length,
                        // ignore: deprecated_member_use
                        onReorder: reorderTasks,

                        proxyDecorator: (child, index, animation) {
                          return Material(
                            elevation: 8,
                            shadowColor: Colors.transparent,
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(22),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: child,
                            ),
                          );
                        },

                        itemBuilder: (context, index) {
                          return KeyedSubtree(
                            key: ValueKey(index),

                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),

                              child: ReorderableDelayedDragStartListener(
                                index: index,

                                child: ToDoTile(
                                  taskName: currentTasks[index][0],
                                  dueTime: currentTasks[index][2],
                                  taskCompleted: currentTasks[index][1],

                                  onChanged: (value) {
                                    checkBoxChanged(value, index);
                                  },

                                  onTap: () {
                                    editTask(index);
                                  },

                                  deleteFunction: (context) {
                                    deleteTask(index);
                                  },

                                  pageNum: widget.pageId,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: createNewTask,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          widget.pageId == 0 ? 'Add checkpoint' : 'Add long-term goal',
        ),
      ),
    );
  }
}
