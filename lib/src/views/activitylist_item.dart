import 'package:flutter/material.dart';
import 'package:youth_card/src/objects/activity.dart';
import 'package:youth_card/src/util/navigator.dart';

class ActivityListItem extends StatelessWidget{
  ActivityListItem(this.activityItem);

  final Activity activityItem;

  @override
  Widget build(BuildContext context){
    return Center(
      child:
      Card(
        child: InkWell(
          onTap: () => goToActivity(context, activityItem),
         child:Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
             ListTile(
              leading: Icon(Icons.album),
              title: Text(activityItem.name),
              subtitle: Text(activityItem.description),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  child: const Text('Read More'),
                  onPressed: () {/* ... */},
                ),
                const SizedBox(width: 8),
                TextButton(
                  child: const Text('Sign up'),
                  onPressed: () {/* ... */},
                ),
                const SizedBox(width: 8),
              ],
            ),
          ]
        )
      )
    )
    );
  }
}