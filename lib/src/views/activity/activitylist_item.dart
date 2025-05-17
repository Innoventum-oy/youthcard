import 'dart:async';

import 'package:flutter/material.dart';
import 'package:youth_card/src/objects/activity.dart';
import 'package:youth_card/src/util/navigator.dart';
import 'package:intl/intl.dart';
import 'package:youth_card/l10n/app_localizations.dart';
import 'package:youth_card/src/util/api_client.dart';
import 'package:provider/provider.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/views/qrscanner.dart';

class ActivityListItem extends StatelessWidget{

  final ApiClient _apiClient = ApiClient();
  final Activity activityItem;
  ActivityListItem(this.activityItem, {super.key});

  int calculateDifference(DateTime date) {
    DateTime now = DateTime.now();
    return DateTime(date.year, date.month, date.day).difference(DateTime(now.year, now.month, now.day)).inDays;
  }
  @override
  Widget build(BuildContext context){
    User user = Provider.of<UserProvider>(context).user;
    String dateinfo = activityItem.nexteventdate==null ? '':(calculateDifference(activityItem.nexteventdate!)!=0 ? DateFormat('kk:mm dd.MM.yyyy').format(activityItem.nexteventdate!) : 'Today ${DateFormat('kk:mm ').format(activityItem.nexteventdate!)}');
    List<Widget> buttons=[];
    buttons.add(ElevatedButton(
      child: Text(AppLocalizations.of(context)!.readMore),
      onPressed: () {
        /* open activity view */
        goToActivity(context, activityItem);
      },
    ));
    buttons.add(const SizedBox(width: 8));

    if(activityItem.registration
        && ( activityItem.maxvisitors==null || (activityItem.maxvisitors??0) > (activityItem.registeredvisitorcount??0) )
        && ( activityItem.registrationenddate==null || activityItem.registrationenddate!.isAfter(DateTime.now()))
        && user.token!=null) {
      buttons.add(ElevatedButton(
        child: Text(AppLocalizations.of(context)!.signUp),
        onPressed: () {
          _apiClient.registerForActivity(activityItem.id, user);
        },
      ));
      buttons.add(const SizedBox(width: 8));
    }
  //  print(activityItem.name!+' access:'+ activityItem.accesslevel.toString());
    if(activityItem.accesslevel >= 20) {
      buttons.add(ElevatedButton(
        child: Text(AppLocalizations.of(context)!.qrScanner),
        onPressed: () {
          Navigator.push(
              context,
           MaterialPageRoute(builder: (context) => QRScanner(activity: activityItem)));
        },
      ));
      buttons.add(const SizedBox(width: 8));
      }
    String subtitle= dateinfo ;
    if(activityItem.registration){
      subtitle+=' [${activityItem.registeredvisitorcount!=null ? activityItem.registeredvisitorcount.toString() : '0'}${activityItem.maxvisitors!=null ? '/${activityItem.maxvisitors}' :''}]';
    }
    if(activityItem.description!=null)subtitle+= '\n${activityItem.description!}';
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
              title: Text((activityItem.name ?? AppLocalizations.of(context)!.unnamedActivity)),
              subtitle: Text(subtitle,
               overflow: TextOverflow.ellipsis,
                maxLines:5),
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
  void showMessage(BuildContext context, String title, Widget content) {
    Timer? timer; // Declare the timer locally
    showDialog(
      context: context,
      builder: (BuildContext builderContext) {
        timer = Timer(Duration(seconds: 5), () {
          Navigator.of(context).pop();
        });

        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: content,
          ),
        );
      },
    ).then((val) {
      if (timer != null && timer!.isActive) {
        timer!.cancel();
      }
    });
  }

}