import 'package:flutter/material.dart';

class BottomGradient extends StatelessWidget {
  final double offset;

  BottomGradient({this.offset: 0.95});

  BottomGradient.noOffset() : offset = 1.0;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
          gradient: LinearGradient(
            end: FractionalOffset(0.0, 0.0),
            begin: FractionalOffset(0.0, offset),
            colors: <Color>[
              Color(0xff222128),
              Color(0x442C2B33),
              Color(0x002C2B33)
            ],
          )),
    );
  }
}

class TextBubble extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  TextBubble(this.text,
      {this.backgroundColor = const Color(0xFF424242),
        this.textColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
        child: Text(
          text,
          style: TextStyle(color: textColor, fontSize: 12.0),
        ),
      ),
    );
  }
}



