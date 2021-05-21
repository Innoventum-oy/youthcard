import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youth_card/src/util/shared_preference.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:youth_card/src/util/app_url.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/providers/user_provider.dart';
class EnvironmentScreen extends StatefulWidget {
  @override
  _EnvironmentScreenState createState() => _EnvironmentScreenState();
}

class _EnvironmentScreenState extends State<EnvironmentScreen> {
  int languageIndex = 0;

  @override
  Widget build(BuildContext context){

    List<SettingsTile> tiles;

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.environment)),
      body: SettingsList(
        sections: [
          SettingsSection(tiles:
            environmentOptions()
          ),
        ],
      ),
    );
  }
 List <SettingsTile> environmentOptions (){
   final Map servers = AppUrl.servers;
   List<SettingsTile> tiles=[];
   servers.forEach((serverTitle,serverUrl)
   {
     tiles.add(
       SettingsTile(
         title: serverTitle,
         trailing: trailingWidget(1),
         onPressed: (BuildContext context) {
           Settings().setValue('server',serverUrl);
           Settings().setValue('servername',serverTitle);

           UserPreferences().removeUser();
           Provider.of<UserProvider>(context, listen: false)
               .clearUser();
           Navigator.pushReplacementNamed(context, '/login');

         },
       )
     );
   });
  return tiles;
 }
  Widget trailingWidget(int index) {
    return (languageIndex == index)
        ? Icon(Icons.check, color: Colors.blue)
        : Icon(null);
  }

  void changeLanguage(int index) {
    setState(() {
      languageIndex = index;
    });
  }
}