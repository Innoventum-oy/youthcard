import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youth_card/src/objects/activity.dart';
import 'package:youth_card/src/providers/index.dart' as objectmodel;
import 'package:youth_card/src/views/activity/activity.dart';
import 'package:youth_card/src/views/activity/place_view.dart';

void goToActivity(
  BuildContext context,
  Activity item, {
  bool isPlace = false,
  Activity? placePreview,
}) {
  final provider =
      context.read<objectmodel.ActivityListProvider?>() ??
      objectmodel.ActivityListProvider();
  objectmodel.ImageProvider imageprovider = objectmodel.ImageProvider();
  _pushWidgetWithFade(
    context,
    isPlace || item.activityType == 'location'
        ? PlaceView(item, provider, previewActivity: placePreview)
        : ActivityView(item, provider, imageprovider),
  );
}

void _pushWidgetWithFade(BuildContext context, Widget widget) {
  Navigator.of(context).push(
    PageRouteBuilder(
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
      pageBuilder:
          (
            BuildContext context,
            Animation animation,
            Animation secondaryAnimation,
          ) {
            return widget;
          },
    ),
  );
}
