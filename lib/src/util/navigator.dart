import 'package:flutter/material.dart';
import 'package:youth_card/src/objects/activity.dart';
import 'package:youth_card/src/providers/objectprovider.dart' as objectmodel;
import 'package:youth_card/src/views/activity/activity.dart';

goToActivity(BuildContext context, Activity item) {
  print('goToActivity called for #'+item.id.toString());
  print(item);
  objectmodel.ActivityProvider provider = objectmodel.ActivityProvider();
  objectmodel.ImageProvider imageprovider = objectmodel.ImageProvider();
  _pushWidgetWithFade(context, ActivityView(item, provider,imageprovider));
}
_pushWidgetWithFade(BuildContext context, Widget widget) {
  Navigator.of(context).push(
    PageRouteBuilder(
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        pageBuilder: (BuildContext context, Animation animation,
            Animation secondaryAnimation) {
          return widget;
        }),
  );
}