import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// An event image with an optional category image fallback.
class ActivityThumbnail extends StatelessWidget {
  const ActivityThumbnail({
    super.key,
    this.eventUrl,
    this.categoryUrl,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  final String? eventUrl;
  final String? categoryUrl;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;

  String? _validUrl(String? candidate) {
    final uri = Uri.tryParse(candidate?.trim() ?? '');
    if (uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host.isNotEmpty) {
      return uri.toString();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fallback = ColoredBox(
      color: colors.primaryContainer,
      child: Center(
        child: Icon(
          Icons.auto_awesome_mosaic_outlined,
          size: 32,
          color: colors.onPrimaryContainer,
        ),
      ),
    );
    final event = _validUrl(eventUrl);
    final category = _validUrl(categoryUrl);
    final url = event ?? category;
    Widget networkImage(String source, {Widget? onError}) => CachedNetworkImage(
      imageUrl: source,
      fit: BoxFit.cover,
      width: width,
      height: height,
      placeholder: (_, _) => fallback,
      errorWidget: (_, _, _) => onError ?? fallback,
    );
    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        width: width,
        height: height,
        child: url == null
            ? fallback
            : networkImage(
                url,
                onError: event != null && category != null && event != category
                    ? networkImage(category)
                    : null,
              ),
      ),
    );
  }
}
