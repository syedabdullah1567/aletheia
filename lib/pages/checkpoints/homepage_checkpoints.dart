import 'package:aletheia/utilities/dark_mode_switcher.dart';
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,

        //pinned: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Logout',
        ),

        title: Text(
          'Checkpoints',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 8,
          ),
        ),

        centerTitle: true,

        actions: const [DarkModeSwitcher(), SizedBox(width: 8)],
      ),
      body: IndexedStack(index: currentIndex, children: _screens),

      bottomNavigationBar: NavigationBar(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,

        selectedIndex: currentIndex,

        elevation: 0,

        destinations: [
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle),
            label: 'Today',
          ),

          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),

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
