import 'package:flutter/material.dart';

/// Displays a benefit image without letting an unavailable image break its view.
class BenefitIcon extends StatelessWidget {
  const BenefitIcon({super.key, this.url, this.radius = 28});

  final String? url;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(url?.trim() ?? '');
    final validUrl =
        uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host.isNotEmpty;
    final fallback = Icon(
      Icons.local_offer_outlined,
      size: radius,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );

    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: validUrl
          ? ClipOval(
              child: Image.network(
                uri.toString(),
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => fallback,
              ),
            )
          : fallback,
    );
  }
}
