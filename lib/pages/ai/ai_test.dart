import 'package:flutter/material.dart';
import '../../utilities/ai/get_gemini_response.dart';
import '../../utilities/dark_mode_switcher.dart';

class AITest extends StatefulWidget {
  const AITest({super.key});

  @override
  State<AITest> createState() => _AITestState();
}

class _AITestState extends State<AITest> {
  final TextEditingController controller = TextEditingController();
  String? answer;
  bool isLoading = false; // Added to track loading state

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _talkToGemini() async {
    if (controller.text.trim().isEmpty) return;

    final String textToSend = controller.text;
    controller.clear(); // Clear input here as soon as send is triggered

    setState(() {
      isLoading = true; // Show loading icon
    });

    String theAnswer = await getGeminiResponse(textToSend);

    setState(() {
      answer = theAnswer;
      isLoading = false; // Hide loading icon
    });
  }

  // Calls the new function we added to the API file
  void _startNewChat() {
    clearChatHistory();
    setState(() {
      answer = null; // Resets UI back to the default greeting
      controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      // Added AppBar with Logout and New Chat buttons
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => Navigator.pushReplacementNamed(context, '/'),
        ),
        actions: [
          const DarkModeSwitcher(),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New Chat',
            onPressed: _startNewChat,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Expanded forces the text display to push the input field to the bottom
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: isLoading
                      ? const CircularProgressIndicator() // Show spinner if thinking
                      : (answer != null
                            ? Text(
                                answer!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            : const Text(
                                'How can I help you today?', // Show default text if no answer yet
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              )),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.only(right: 60),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  labelText: 'Ask me anything',
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: isLoading
            ? null
            : _talkToGemini, // Disables button when loading
        tooltip: 'Send to Gemini',
        elevation: 10,
        child: const Icon(Icons.send),
      ),
    );
  }
}
