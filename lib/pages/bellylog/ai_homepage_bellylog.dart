import 'package:aletheia/utilities/uniform_appbar.dart';
import 'package:flutter/material.dart';

class AiHomepageBellylog extends StatelessWidget {
  const AiHomepageBellylog({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UniformAppbar(
        leadIcon: Icon(Icons.abc),
        titleText: 'AI Insights',
        onPress: () => Navigator.pop(context),
      ),
    );
  }
}
