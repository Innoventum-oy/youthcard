import 'package:flutter/material.dart';
import 'package:youth_card/src/objects/activity.dart';

class ActivityListItem extends StatelessWidget{
  ActivityListItem(this.activityItem);

  final Activity activityItem;

  @override
  Widget build(BuildContext context){
    return Card(
      child: new Text(activityItem.name),
    );
  }
}