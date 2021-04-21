import 'package:flutter/material.dart';
import 'package:youth_card/src/objects/activity.dart';
import 'package:youth_card/src/util/navigator.dart';
import 'package:intl/intl.dart';

class ActivityListItem extends StatelessWidget{
  ActivityListItem(this.activityItem);

  final Activity activityItem;

  int calculateDifference(DateTime date) {
    DateTime now = DateTime.now();
    return DateTime(date.year, date.month, date.day).difference(DateTime(now.year, now.month, now.day)).inDays;
  }
  @override
  Widget build(BuildContext context){
    String dateinfo = activityItem.nexteventdate==null ? '':(calculateDifference(activityItem.nexteventdate!)!=0 ? DateFormat('kk:mm dd.MM.yyyy').format(activityItem.nexteventdate!) : 'Today '+DateFormat('kk:mm ').format(activityItem.startdate!));
    return Center(
      child:
      Card(
        child: InkWell(
          onTap: () => goToActivity(context, activityItem),
         child:Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
             ListTile(
              leading: Icon(Icons.event),
              title: Text((activityItem.name != null ? activityItem.name: 'Unnamed event')!),
              subtitle: Text(dateinfo +(activityItem.description==null ? '' : '\n'+activityItem.description!)),
               isThreeLine: true,
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