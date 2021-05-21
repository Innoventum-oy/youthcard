import 'package:settings_ui/settings_ui.dart';
import 'package:youth_card/src/util/app_url.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:youth_card/src/views/settings/languageselect.dart';
import 'package:youth_card/src/views/settings/environment.dart';
import 'package:package_info/package_info.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:youth_card/src/util/shared_preference.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool lockInBackground = true;
  bool notificationsEnabled = true;
  String servername='Loading..';
  String appName ='';
  String packageName = '';
  String version = '';
  String buildNumber = '';

  _SettingsScreenState() {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) =>setState(() {
      //print('loaded packageinfo from platform');
      appName = packageInfo.appName;
      packageName = packageInfo.packageName;
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    }));
    Settings().getValue('servername').then((val) => setState((){
     // print('loaded servername');
      servername = val;
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(AppLocalizations.of(context)!.youthcardSettings)),
      body: buildSettingsList(),
    );
  }

  Widget buildSettingsList() {
    return SettingsList(
      sections: [
        SettingsSection(
          title: 'Common',
          tiles: [
            SettingsTile(
              title: AppLocalizations.of(context)!.language,
              subtitle: 'English',
              leading: Icon(Icons.language),
              onPressed: (context) {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => LanguagesScreen(),
                ));
              },
            ),
            SettingsTile(
              title: AppLocalizations.of(context)!.environment,
              subtitle: servername,
              leading: Icon(Icons.cloud_queue),
              onPressed: (context) {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => EnvironmentScreen(),
                ));
              },
            ),
          ],
        ),
        SettingsSection(
          title: 'Account',
          tiles: [
            SettingsTile(
                title: AppLocalizations.of(context)!.phoneNumber,
                leading: Icon(Icons.phone)),
            SettingsTile(
                title: AppLocalizations.of(context)!.email,
                leading: Icon(Icons.email)),
            SettingsTile(
                title: AppLocalizations.of(context)!.logout,
                leading: Icon(Icons.exit_to_app)),
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
          title: AppLocalizations.of(context)!.miscSettings,
          tiles: [
            SettingsTile(
                title: AppLocalizations.of(context)!.termsOfService,
                leading: Icon(Icons.description)),
            SettingsTile(
                title: AppLocalizations.of(context)!.about,
                leading: Icon(Icons.collections_bookmark)),
          ],
        ),
        CustomSection(
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
    print('getVersionInfo called');

      return Text(appName + ' v.' + version + '(' + buildNumber + ')',
          style: TextStyle(color: Color(0xFF777777)));
    }

}
