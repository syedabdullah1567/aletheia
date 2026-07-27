import 'package:flutter/material.dart';
import 'package:aletheia/pages/checkpoints/tasks.dart';

class HomepageCheckpoints extends StatefulWidget {
  const HomepageCheckpoints({super.key});

  @override
  State<HomepageCheckpoints> createState() => _HomepageCheckpointsState();
}

class _HomepageCheckpointsState extends State<HomepageCheckpoints> {
  int currentIndex = 0;

  final List<Widget> _screens = [
    const ToDoPage(pageId: 0),
    const ToDoPage(pageId: 1),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: _screens),

      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,

        backgroundColor: colorScheme.surface,

        indicatorColor: colorScheme.primaryContainer,

        elevation: 0,

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline_rounded),
            selectedIcon: Icon(Icons.check_circle_rounded),
            label: 'Today',
          ),

          NavigationDestination(
            icon: Icon(Icons.calendar_month),
            selectedIcon: Icon(Icons.auto_awesome_rounded),
            label: 'Long-term',
          ),
        ],

        onDestinationSelected: (value) {
          setState(() {
            currentIndex = value;
          });
        },
      ),
    );
  }
}
