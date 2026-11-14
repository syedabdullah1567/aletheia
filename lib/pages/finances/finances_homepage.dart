import 'package:aletheia/utilities/uniform_appbar.dart';
import 'package:flutter/material.dart';

class FinancesHomepage extends StatelessWidget {
  const FinancesHomepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: UniformAppbar(
          leadIcon: const Icon(Icons.arrow_back_rounded),
          titleText: "Finances",
          onPress: () => Navigator.pop(context),
        ),
        body: const Center(
          child: Text('Welcome to the Finances Homepage!'),
        ),
      ),
    );
  }
}