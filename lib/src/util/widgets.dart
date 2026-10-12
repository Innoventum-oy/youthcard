import 'package:flutter/material.dart';
import 'package:youth_card/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/providers/index.dart' as object_model;
import 'package:youth_card/src/views/activity/categorisedactivitylist.dart';
import 'package:youth_card/src/views/calendar.dart';

Widget longButtons(
  String title,
  Function()? fun, {
  Color? color,
  Color? textColor,
}) {
  return Builder(
    builder: (context) => SizedBox(
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
    ),
  );
}

Text label(String title) => Text(title);
Text headingLabel(String title) =>
    Text(title, style: TextStyle(fontWeight: FontWeight.bold));
InputDecoration buildInputDecoration(String hintText, IconData icon) {
  return InputDecoration(
    prefixIcon: Icon(icon),
    // hintText: hintText,
    contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.0)),
  );
}

void handleNotifications(dynamic notifications, context) {
  if (notifications != null) {
    List<Widget> inforows = [];
    for (String notification in notifications) {
      inforows.add(
        Padding(padding: const EdgeInsets.all(8.0), child: Text(notification)),
      );
    }
    notifyDialog(
      AppLocalizations.of(context)!.notification,
      Column(children: inforows),
      context,
    );
    //display notifications in alert dialog
  }
}

void notifyDialog(String? titleText, Widget text, context) {
  showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(titleText ?? AppLocalizations.of(context)!.notification),
      content: SingleChildScrollView(child: text),
      actions: <Widget>[
        ElevatedButton(
          child: Text(AppLocalizations.of(context)!.ok),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
        ),
      ],
    ),
  );
}

Widget bottomNavigation(BuildContext context, {int currentIndex = 0}) {
  object_model.ImageProvider imageprovider = object_model.ImageProvider();
  User user = Provider.of<UserProvider>(context).user;
  final strings = AppLocalizations.of(context)!;
  final colors = Theme.of(context).colorScheme;
  final labels = [
    strings.home,
    strings.discover,
    strings.calendar,
    if (user.token != null) strings.myCard,
  ];
  void select(int index) {
    if (index == currentIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/dashboard');
        break;

      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CategorisedActivityList(imageprovider),
          ),
        );

        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ActivityCalendar()),
        );
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/card');
        break;
    }
  }

  return SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(24, 6, 24, 8),
      child: SizedBox(
        height: 56,
        child: Material(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                for (var index = 0; index < labels.length; index++)
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => select(index),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                          vertical: 9,
                          horizontal: 3,
                        ),
                        decoration: BoxDecoration(
                          color: index == currentIndex
                              ? colors.primaryContainer
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          labels[index],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: index == currentIndex
                                    ? colors.primary
                                    : colors.onSurfaceVariant,
                                fontWeight: index == currentIndex
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
