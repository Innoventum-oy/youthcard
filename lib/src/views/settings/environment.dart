import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';

import 'package:provider/provider.dart';
import 'package:youth_card/src/util/shared_preference.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:youth_card/src/util/app_url.dart';
import 'package:youth_card/src/providers/user_provider.dart';

class EnvironmentScreen extends StatefulWidget {
  final bool wrap = false;

  EnvironmentScreen({required wrap});

  @override
  _EnvironmentScreenState createState() => _EnvironmentScreenState();
}

class _EnvironmentScreenState extends State<EnvironmentScreen> {

  String servername = '';

  _EnvironmentScreenState() {
    Settings().getServerName().then((val) => setState(() {
          servername = val;
        }));
  }

  @override
  Widget build(BuildContext context) {
    //List<SettingsTile> tiles;
    // todo: handle wrap parameter and return widget with or without scaffold depending of use case
    // print('Wrap:'+(widget.wrap ? 'yes' :'no'));
    return wrappedList();
  }

  Widget environmentSettingsList() {
    return Column(
      children: <Widget>[
        Expanded(child: SettingsSection(tiles: environmentOptions())),
      ],
    );
  }

  Widget wrappedList() {
    return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.environment)),
        body: environmentSettingsList());
  }

  List<SettingsTile> environmentOptions() {
    final Map servers = AppUrl.servers;
    List<SettingsTile> tiles = [];
    servers.forEach((serverTitle, serverUrl) {
      tiles.add(SettingsTile(
        title: serverTitle,
        // subtitle: serverUrl,

        leading: trailingWidget(serverTitle),
        onPressed: (BuildContext context) {
          Settings().setValue('server', serverUrl);
          Settings().setValue('servername', serverTitle);
          if(AppUrl.anonymousApikeys.containsKey(serverTitle)) {
            Settings().setValue(
                'anonymousapikey', AppUrl.anonymousApikeys[serverTitle]);
              print("Anonymous api key for " + serverTitle + " set to " +AppUrl.anonymousApikeys[serverTitle]!);
            }
          else
            Settings().setValue('anonymousapikey', null);

          Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
          //pushReplacementNamed(context, '/login');
          UserPreferences().removeUser();
          Provider.of<UserProvider>(context, listen: false).clearUser();
        },
      ));
    });
    return tiles;
  }

  Widget trailingWidget(String currentname) {
    return (servername == currentname)
        ? Icon(Icons.check, color: Colors.blue)
        : Icon(null);
  }
}
