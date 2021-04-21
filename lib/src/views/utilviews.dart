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


///
/// copy-pasta from : https://github.com/flutter/flutter/issues/13478
///
class FittedCircleAvatar extends StatelessWidget {
  /// Creates a circle that represents a user.
  const FittedCircleAvatar({
    Key? key,
    required this.child,
    required this.backgroundColor,
    required this.backgroundImage,
    required this.foregroundColor,
    this.radius: 20.0,
    this.fit: BoxFit.cover,
  }) : super(key: key);

  /// The widget below this widget in the tree.
  ///
  /// Typically a [Text] widget. If the [CircleAvatar] is to have an image, use
  /// [backgroundImage] instead.
  final Widget child;

  /// The color with which to fill the circle. Changing the background
  /// color will cause the avatar to animate to the color.
  ///
  /// If a background color is not specified, the theme's primary color is used.
  final Color backgroundColor;

  /// The default text color for text in the circle.
  ///
  /// Falls back to white if a background color is specified, or the primary
  /// text theme color otherwise.
  final Color foregroundColor;

  /// The background image of the circle. Changing the background
  /// image will cause the avatar to animate to the image.
  ///
  /// If the [CircleAvatar] is to have the user's initials, use [child] instead.
  final ImageProvider backgroundImage;

  /// The size of the avatar. Changing the radius will cause the
  /// avatar to animate to the size.
  ///
  /// Defaults to 20 logical pixels.
  final double radius;

  /// Avatar Image BoxFit.
  ///
  /// Defaults to cover.
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final ThemeData theme = Theme.of(context);
    TextStyle textStyle = theme.primaryTextTheme.title!;
    if (foregroundColor != null) {
      textStyle = textStyle.copyWith(color: foregroundColor);
    } else if (backgroundColor != null) {
      switch (ThemeData.estimateBrightnessForColor(backgroundColor)) {
        case Brightness.dark:
          textStyle = textStyle.copyWith(color: Colors.white);
          break;
        case Brightness.light:
          textStyle = textStyle.copyWith(color: Colors.black);
          break;
      }
    }
    return AnimatedContainer(
      width: radius * 2.0,
      height: radius * 2.0,
      duration: kThemeChangeDuration,
      decoration: BoxDecoration(
        color: backgroundColor,
        image: backgroundImage != null
            ? DecorationImage(
          image: backgroundImage,
          fit: fit,
        )
            : null,
        shape: BoxShape.circle,
      ),
      child: child != null
          ? Center(
          child: MediaQuery(
            // Need to reset the textScaleFactor here so that the
            // text doesn't escape the avatar when the textScaleFactor is large.
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: DefaultTextStyle(
              style: textStyle.copyWith(color: foregroundColor),
              child: child,
            ),
          ))
          : null,
    );
  }
}
