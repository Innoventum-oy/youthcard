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
  bool wrap = false;

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
    List<SettingsTile> tiles;
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
        titleMaxLines: 3,
        trailing: trailingWidget(serverTitle),
        onPressed: (BuildContext context) {
          Settings().setValue('server', serverUrl);
          Settings().setValue('servername', serverTitle);


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
