import 'package:provider/provider.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:youth_card/src/views/settings/environment.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:youth_card/l10n/app_localizations.dart';
import 'package:youth_card/src/util/shared_preference.dart';
import 'package:youth_card/src/util/local_storage.dart';

import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/views/webpagetextcontent.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  bool lockInBackground = true;
  bool notificationsEnabled = true;
  String servername='Loading..';
  String appName ='';
  String packageName = '';
  String version = '';
  String buildNumber = '';
  String language = 'Loading..';

  SettingsScreenState() {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) =>setState(() {

      appName = packageInfo.appName;
      packageName = packageInfo.packageName;
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    }));
    Settings().getServerName().then((val) => setState((){

      servername = val;
    }));
    Settings().getLanguage().then((val) => setState((){
      language = val;
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(AppLocalizations.of(context)!.youthcardSettings)),
      body: buildSettingsList(),
        bottomNavigationBar: BottomAppBar(
            child:
            Row(

              children:[
                Image.asset('images/erasmusplus.png',
                    height:40),
            Flexible(child:Text(AppLocalizations.of(context)!.erasmusDisclaimer,
                style:TextStyle(fontSize:10,),
                  )
            ),

             ],
            )
        )
    );
  }

  Widget buildSettingsList() {
    final user = Provider.of<UserProvider>(context, listen: false).user;

    return SettingsList(
      sections: [
        SettingsSection(
          title: Text(AppLocalizations.of(context)!.settingsCommon,
          style: TextStyle(fontSize: 13)),
          tiles: [
           /* SettingsTile(
              title: AppLocalizations.of(context)!.language,
              subtitle: language,
              leading: Icon(Icons.language),
              onPressed: (context) {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => LanguagesScreen(),
                ));
              },
            ),*/
            SettingsTile(
              title: Text(AppLocalizations.of(context)!.environment,
                style: TextStyle(fontSize: 13),
    ),
              //subtitle: Text(servername),
              leading: Icon(Icons.cloud_queue),
              onPressed: (context) {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => EnvironmentScreen(wrap:true),
                ));
              },
            ),
          ],
        ),
       if(user.token!=null) SettingsSection(
          title: Text(AppLocalizations.of(context)!.settingsAccount,
          style: TextStyle(fontSize: 13)),
          tiles: [
            SettingsTile(
                title: Text(AppLocalizations.of(context)!.contactInformation,
                  style: TextStyle(fontSize: 13),
    ),
                leading: Icon(Icons.phone),
                onPressed: (context) {
                  Navigator.pushReplacementNamed(context, '/contactmethods');
                },
            ),
            SettingsTile(
              title: Text(AppLocalizations.of(context)!.userInformation,
              style: TextStyle(fontSize: 13)),
              leading: Icon(Icons.account_circle),
              onPressed: (context) {
                Navigator.pushReplacementNamed(context, '/userform');
              },
            ),
           /* SettingsTile(
                title: AppLocalizations.of(context)!.email,
                leading: Icon(Icons.email)),*/
            SettingsTile(
                title: Text(AppLocalizations.of(context)!.logout,
                style: TextStyle(fontSize: 13),
    ),
                leading: Icon(Icons.logout),
                onPressed: (BuildContext context) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
                UserPreferences().removeUser();
                Provider.of<UserProvider>(context, listen: false).clearUser();
              }),
          ],
        ),
        /*
        SettingsSection(
          title: 'Security',
          tiles: [
            SettingsTile.switchTile(
              title: 'Lock app in background',
              leading: Icon(Icons.phonelink_lock),
              switchValue: lockInBackground,
              onToggle: (bool value) {
                setState(() {
                  lockInBackground = value;
                  notificationsEnabled = value;
                });
              },
            ),
            SettingsTile.switchTile(
                title: 'Use fingerprint',
                subtitle: 'Allow application to access stored fingerprint IDs.',
                leading: Icon(Icons.fingerprint),
                onToggle: (bool value) {},
                switchValue: false),
            SettingsTile.switchTile(
              title: 'Change password',
              leading: Icon(Icons.lock),
              switchValue: true,
              onToggle: (bool value) {},
            ),
            SettingsTile.switchTile(
              title: 'Enable Notifications',
              enabled: notificationsEnabled,
              leading: Icon(Icons.notifications_active),
              switchValue: true,
              onToggle: (value) {},
            ),
          ],
        ),
        */
        SettingsSection(
          title: Text(AppLocalizations.of(context)!.settingsMisc,
            style: TextStyle(fontSize: 13),
    ),
          tiles: [
            SettingsTile(
                title: Text(AppLocalizations.of(context)!.termsOfService,
                  style: TextStyle(fontSize: 13),
    ),
                leading: Icon(Icons.description),
    onPressed: (context) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ContentPageView('privacy-policy'),
      ));
    }
            ),
           /* SettingsTile(
                title: AppLocalizations.of(context)!.about,
                leading: Icon(Icons.collections_bookmark)),*/
            SettingsTile(
            title: Text(AppLocalizations.of(context)!.clearCache,
            style: TextStyle(fontSize: 13),
    ),
            leading: Icon(Icons.clear), onPressed: (BuildContext context) {
              getFileStorage().clear();
            }),
            SettingsTile(
                title: Text(AppLocalizations.of(context)!.showWelcomeScreen,
                  style: TextStyle(fontSize: 13),
    ),
                leading: Icon(Icons.logout),
                onPressed: (BuildContext context) {
                  Navigator.pushNamedAndRemoveUntil(context, '/welcome', (_) => false);


                }),

      ],
        ),
        CustomSettingsSection(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 22, bottom: 8),
                child: Image.asset(
                  'images/settings.png',
                  height: 50,
                  width: 50,
                  color: Color(0xFF777777),
                ),
              ),
              getVersionInfo(),
            ],
          ),
        ),
      ],
    );
  }

  Widget getVersionInfo() {


      return Text('$appName v.$version($buildNumber)',
          style: TextStyle(color: Color(0xFF777777)));
    }

}
