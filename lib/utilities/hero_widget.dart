import 'package:flutter/material.dart';

class HeroWidget extends StatelessWidget {
  HeroWidget({super.key, required this.title});

  String title;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Hero(
          tag: 'Hero1',
          child: Padding(
            padding: EdgeInsets.only(top: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset('assets/nature.jpg'),
            ),
          ),
        ),
        FittedBox(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 50,
              letterSpacing: 20,
            ),
          ),
        ),
      ],
    );
  }
}
