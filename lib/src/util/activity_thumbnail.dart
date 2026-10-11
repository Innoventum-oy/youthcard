import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/util/category_cover_images.dart';

/// An event image with an optional category image fallback.
class ActivityThumbnail extends StatefulWidget {
  const ActivityThumbnail({
    super.key,
    this.eventUrl,
    this.categoryUrl,
    this.categoryId,
    this.categoryImageId,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  final String? eventUrl;
  final String? categoryUrl;
  final int? categoryId;
  final String? categoryImageId;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;

  @override
  State<ActivityThumbnail> createState() => _ActivityThumbnailState();
}

class _ActivityThumbnailState extends State<ActivityThumbnail> {
  String? _lookupKey;
  Future<String?>? _categoryFuture;

  String? _validUrl(String? candidate) {
    final uri = Uri.tryParse(candidate?.trim() ?? '');
    if (uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host.isNotEmpty) {
      if (uri.path.startsWith('/openimage/') &&
          uri.queryParameters.containsKey('PHPSESSID')) {
        final query = Map<String, String>.from(uri.queryParameters)
          ..remove('PHPSESSID');
        return uri
            .replace(
              query: query.isEmpty ? '' : Uri(queryParameters: query).query,
            )
            .toString();
      }
      return uri.toString();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final token = context.watch<UserProvider?>()?.user.token;
    final lookupKey = '${widget.categoryImageId}:${widget.categoryId}:$token';
    if (_lookupKey != lookupKey) {
      _lookupKey = lookupKey;
      _categoryFuture = widget.categoryImageId != null
          ? CategoryCoverImages.shared.forImageId(widget.categoryImageId)
          : widget.categoryId != null
          ? CategoryCoverImages.shared.forCategory(
              widget.categoryId,
              token: token,
            )
          : null;
    }
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
    final event = _validUrl(widget.eventUrl);
    Widget networkImage(String source, {Widget? onError}) => CachedNetworkImage(
      imageUrl: source,
      fit: BoxFit.cover,
      width: widget.width,
      height: widget.height,
      placeholder: (_, _) => fallback,
      errorWidget: (_, _, _) => onError ?? fallback,
    );
    Widget imageFor(String? resolvedCategory) {
      final category =
          _validUrl(widget.categoryUrl) ?? _validUrl(resolvedCategory);
      final url = event ?? category;
      if (url == null) return fallback;
      return networkImage(
        url,
        onError: event != null && category != null && event != category
            ? networkImage(category)
            : null,
      );
    }

    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: _categoryFuture == null
            ? imageFor(null)
            : FutureBuilder<String?>(
                future: _categoryFuture,
                builder: (context, snapshot) => imageFor(snapshot.data),
              ),
      ),
    );
  }
}
