import 'package:flutter/material.dart';
import 'package:youth_card/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/providers/index.dart' as object_model;
import 'package:youth_card/src/views/activity/categorisedactivitylist.dart';
import 'package:youth_card/src/views/calendar.dart';

Widget longButtons(String title, Function()? fun,
    {Color? color, Color? textColor}) {
  return Builder(builder: (context) => SizedBox(
    width: double.infinity,
    child: FilledButton(
      onPressed: fun == null ? null : () => fun(),
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        minimumSize: const Size.fromHeight(48),
      ),
      child: Text(title, textAlign: TextAlign.center),
    ),
  ));
}

label(String title) => Text(title);
headingLabel(String title) => Text(title,style: TextStyle(fontWeight: FontWeight.bold),);
InputDecoration buildInputDecoration(String hintText, IconData icon) {
  return InputDecoration(
    prefixIcon: Icon(icon),
    // hintText: hintText,
    contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.0)),
  );
}
handleNotifications(dynamic notifications,context)
{
  if (notifications != null)
  {
    List<Widget> inforows=[];
    for( String notification in notifications){

      inforows.add(Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(notification)))
      ;
    }
    notifyDialog(AppLocalizations.of(context)!.notification,Column(children:inforows),context);
    //display notifications in alert dialog

  }
}
notifyDialog(String? titleText,Widget text, context)
{
  showDialog<String>(
      context: context,
      builder:(BuildContext context) =>AlertDialog(
        title: Text(titleText ?? AppLocalizations.of(context)!.notification),
        content: SingleChildScrollView(
            child:text
        ),
        actions:<Widget>[
          ElevatedButton(
              child: Text(AppLocalizations.of(context)!.ok),
              onPressed:(){
                Navigator.of(context, rootNavigator: true).pop();

              }
          )
        ],
      )
  );

}

Widget bottomNavigation(context,{int currentIndex=0}) {
  object_model.ImageProvider imageprovider = object_model.ImageProvider();
  User user = Provider.of<UserProvider>(context).user;
  return NavigationBar(
      selectedIndex: currentIndex,
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: AppLocalizations.of(context)!.btnDashboard,
        ),
        NavigationDestination(
          icon: const Icon(Icons.search),
          label: AppLocalizations.of(context)!.activities,
        ),
        NavigationDestination(
          icon: const Icon(Icons.calendar_month_outlined),
          selectedIcon: const Icon(Icons.calendar_month),
          label: AppLocalizations.of(context)!.calendar,
        ),
       if(user.token!=null) NavigationDestination(
          icon: const Icon(Icons.card_membership_outlined),
          selectedIcon: const Icon(Icons.card_membership),
          label: AppLocalizations.of(context)!.myCard,
        ),
      ],
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/dashboard');
            break;

          case 1:
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        CategorisedActivityList(imageprovider))

            );

            break;
          case 2:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ActivityCalendar(
                object_model.ActivityListProvider(), imageprovider,
              )),
            );
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/card');
            break;
        }
      });
}
