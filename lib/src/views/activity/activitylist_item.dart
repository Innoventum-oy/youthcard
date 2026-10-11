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
import 'package:youth_card/src/util/activity_thumbnail.dart';

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
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.fromLTRB(24, 6, 24, 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => goToActivity(context, activityItem),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ActivityThumbnail(eventUrl: activityItem.coverpictureurl,
                    categoryId: activityItem.activityClassId,
                    width: 96, height: 96),
                const SizedBox(width: 14),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(activityItem.name ??
                        AppLocalizations.of(context)!.unnamedActivity,
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(subtitle, maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                  ],
                )),
              ]),
              if (buttons.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 4, children: buttons),
              ],
            ],
          ),
        ),
      ),
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
