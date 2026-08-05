import 'package:aletheia/data/palimora_database.dart';
import 'package:aletheia/utilities/checkpoints/buttons.dart';
import 'package:aletheia/utilities/custom_date_time.dart';
import 'package:aletheia/utilities/uniform_appbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class JournalEntry extends StatefulWidget {
  const JournalEntry({super.key});

  @override
  State<JournalEntry> createState() => _JournalEntryState();
}

class _JournalEntryState extends State<JournalEntry> {
  final TextEditingController _controller = TextEditingController();

  final PalimoraDatabase db = PalimoraDatabase();

  @override
  void dispose() {
    _controller.dispose(); // Always dispose controllers to avoid memory leaks
    super.dispose();
  }

  void saveJournalEntry(DateTime currentTime, String entry) {
    if (entry == '') {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a journal entry before continuing.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    String timestampKey = DateFormat('yyyy-MM-dd HH:mm:ss').format(currentTime);

    db.journalEntries[timestampKey] = entry;

    db.updateDataBase(4);

    _controller.clear();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    DateTime currentTime = DateTime.now();
    return Scaffold(
      // Prevents layout shift/overflow issues when keyboard opens
      resizeToAvoidBottomInset: true,

      appBar: UniformAppbar(
        leadIcon: const Icon(Icons.arrow_back_rounded),
        titleText: 'Reminisce your day',
        onPress: () => Navigator.pop(context),
      ),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Center(
              child: FractionallySizedBox(
                widthFactor: constraints.maxWidth > 500 ? 0.7 : 1,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Fixed top section
                      DateTimePickerBanner(
                        currentTime: currentTime,
                        onTimeChanged: (newTime) {
                          setState(() {
                            currentTime = newTime;
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      // Takes remaining vertical height automatically
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          expands: true,
                          maxLines: null,
                          minLines: null,
                          textAlignVertical: TextAlignVertical.top,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          enableSuggestions: true,
                          autocorrect: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            hintText: 'Start Journaling...',
                            hintStyle: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          MyButton(
                            text: 'Cancel',
                            onPressed: () {
                              _controller.clear();
                              Navigator.pop(context);
                            },
                            isPrimary: false,
                          ),
                          MyButton(
                            text: 'Save',
                            onPressed: () =>
                                saveJournalEntry(currentTime, _controller.text),
                          ),
                        ],
                      ),
                    ],
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
