import 'package:aletheia/data/palimora_database.dart';
import 'package:aletheia/utilities/uniform_appbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ViewJournalEntriesPage extends StatefulWidget {
  const ViewJournalEntriesPage({super.key});

  @override
  State<ViewJournalEntriesPage> createState() => _ViewJournalEntriesPageState();
}

class _ViewJournalEntriesPageState extends State<ViewJournalEntriesPage> {
  final PalimoraDatabase db = PalimoraDatabase();

  @override
  void initState() {
    super.initState();
    _loadJournalData();
  }

  void _loadJournalData() {
    setState(() {
      db.loadData(4); // Load JOURNALENTRIES (num == 4)
    });
  }

  // Format key strings (e.g. "2026-08-05 14:30:00") into readable date/time
  String _formatTimestamp(String timestampKey) {
    try {
      DateTime parsedDate = DateFormat(
        'yyyy-MM-dd HH:mm:ss',
      ).parse(timestampKey);
      return DateFormat('EEE, MMM d, yyyy • h:mm a').format(parsedDate);
    } catch (e) {
      return timestampKey; // Fallback to raw string if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sort entries to show newest at top
    final sortedEntries = db.journalEntries.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    return Scaffold(
      appBar: UniformAppbar(
        leadIcon: const Icon(Icons.arrow_back_rounded),
        titleText: 'Your Journal Entries',
        onPress: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: FractionallySizedBox(
                widthFactor: constraints.maxWidth > 500 ? 0.7 : 1,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: sortedEntries.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.book_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No journal entries yet.',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text('Your saved reflections will appear here.'),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: sortedEntries.length,
                          itemBuilder: (context, index) {
                            final entry = sortedEntries[index];
                            final formattedDate = _formatTimestamp(entry.key);

                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header: Date & Icon
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_today_rounded,
                                          size: 18,
                                          color: Colors.blueAccent,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          formattedDate,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 24, thickness: 1),
                                    // Entry Body
                                    Text(
                                      entry.value,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
