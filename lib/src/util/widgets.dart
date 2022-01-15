import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/views/activity/activitylist.dart';
import 'package:youth_card/src/providers/objectprovider.dart' as objectmodel;
import 'package:youth_card/src/views/activity/categorisedactivitylist.dart';

MaterialButton longButtons(String title, Function()? fun,
    {Color color: const Color(0xfff063057), Color textColor: Colors.white}) {
  return MaterialButton(
    onPressed: fun,
    textColor: textColor,
    color: color,
    child: SizedBox(
      width: double.infinity,
      child: Text(
        title,
        textAlign: TextAlign.center,
      ),
    ),
    height: 45,
    minWidth: 600,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10))),
  );
}

label(String title) => Text(title);

InputDecoration buildInputDecoration(String hintText, IconData icon) {
  return InputDecoration(
    prefixIcon: Icon(icon, color: Color.fromRGBO(50, 62, 72, 1.0)),
    // hintText: hintText,
    contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
  );
}
notifyDialog(String text, context)
{
  showDialog<String>(
      context: context,
      builder:(BuildContext context) =>AlertDialog(
        title: Text(AppLocalizations.of(context)!.notification),
        content: SingleChildScrollView(
            child:Text(text)
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
  objectmodel.ImageProvider imageprovider = objectmodel.ImageProvider();
  return BottomNavigationBar(
      currentIndex: currentIndex,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: AppLocalizations.of(context)!.btnDashboard,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: AppLocalizations.of(context)!.activities,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.card_membership),
          label: AppLocalizations.of(context)!.myCard,
        ),
      ],
      selectedItemColor: Colors.deepOrange,
      onTap: (index) {
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
            Navigator.pushReplacementNamed(context, '/card');
            break;
        }
      });
}