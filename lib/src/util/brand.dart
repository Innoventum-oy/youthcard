import 'package:flutter/material.dart';

/// Colors from the Youth Card fresh brand concept.
abstract final class YouthCardBrand {
  static const mint = Color(0xFF5DE2C1);
  static const navy = Color(0xFF17313D);
  static const teal = Color(0xFF087F77);
  static const coral = Color(0xFFFF705E);
}

class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key, this.height = 72});

  final double height;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Image.asset(
      dark
          ? 'images/brand/wordmark-dark.png'
          : 'images/brand/wordmark-light.png',
      height: height,
      fit: BoxFit.contain,
      alignment: Alignment.centerLeft,
      semanticLabel: 'Youth Card',
    );
  }
}

class BrandIcon extends StatelessWidget {
  const BrandIcon({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(size * 0.22),
    child: Image.asset(
      'images/brand/app-icon.png',
      width: size,
      height: size,
      fit: BoxFit.cover,
      semanticLabel: 'Youth Card',
    ),
  );
}
