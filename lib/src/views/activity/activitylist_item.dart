import 'package:flutter/material.dart';
import 'package:youth_card/src/objects/activity.dart';
import 'package:youth_card/src/util/navigator.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:youth_card/src/util/api_client.dart';
import 'package:provider/provider.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/util/utils.dart';
import 'package:youth_card/src/views/qrscanner.dart';

class ActivityListItem extends StatelessWidget{
  ActivityListItem(this.activityItem);
  ApiClient _apiClient = ApiClient();
  final Activity activityItem;

  int calculateDifference(DateTime date) {
    DateTime now = DateTime.now();
    return DateTime(date.year, date.month, date.day).difference(DateTime(now.year, now.month, now.day)).inDays;
  }
  @override
  Widget build(BuildContext context){
    User user = Provider.of<UserProvider>(context).user;
    String dateinfo = activityItem.nexteventdate==null ? '':(calculateDifference(activityItem.nexteventdate!)!=0 ? DateFormat('kk:mm dd.MM.yyyy').format(activityItem.nexteventdate!) : 'Today '+DateFormat('kk:mm ').format(activityItem.startdate!));
    List<Widget> buttons=[];
    buttons.add(TextButton(
      child: Text(AppLocalizations.of(context)!.readMore),
      onPressed: () {
        /* open activity view */
        goToActivity(context, activityItem);
      },
    ));
    buttons.add(const SizedBox(width: 8));
    if(activityItem.registration) {
      buttons.add(TextButton(
        child: Text(AppLocalizations.of(context)!.signUp),
        onPressed: () {
          print('signing up for activity {$activityItem.name}');
          _apiClient.registerForActivity(activityItem.id, user);
        },
      ));
      buttons.add(const SizedBox(width: 8));
    }
    if(activityItem.accesslevel >= 20) {
      buttons.add(TextButton(
        child: Text(AppLocalizations.of(context)!.qrScanner),
        onPressed: () {
          Navigator.push(
              context,
           MaterialPageRoute(builder: (context) => QRScanner(activity: activityItem)));
        },
      ));
      buttons.add(const SizedBox(width: 8));
      }
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
              title: Text((activityItem.name != null ? activityItem.name: AppLocalizations.of(context)!.unnamedActivity)!),
              subtitle: Text(dateinfo +(activityItem.description==null ? '' : '\n'+activityItem.description!)),
               isThreeLine: true,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: buttons,
            ),
          ]
        )
      )
    )
    );
  }



}