import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:youth_card/src/util/shared_preference.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // important

class LanguagesScreen extends StatefulWidget {
  @override
  _LanguagesScreenState createState() => _LanguagesScreenState();
}

class _LanguagesScreenState extends State<LanguagesScreen> {
  String currentLocale = '';

  _LanguagesScreenState() {
    Settings().getLanguage().then((val) => setState(() {
      currentLocale = val;
    }));
  }

  @override
  Widget build(BuildContext context){

   // List<SettingsTile> tiles;

    return Scaffold(
      appBar: AppBar(title: Text('Languages')),
      body: SettingsList(
        sections: [
          SettingsSection(tiles: languageOptions()),
        ],
      ),
    );
  }
  List<SettingsTile> languageOptions()
  {
    List<SettingsTile> options = [];
    for(var locale in AppLocalizations.supportedLocales)
      {
      options.add(
        SettingsTile(
          title: locale.toLanguageTag(),
          leading: trailingWidget(locale.languageCode),
          onPressed: (BuildContext context) {
            changeLanguage(locale.languageCode);
          },
        ),
      );
      }
    return options;
  }
  Widget trailingWidget(String locale) {
    return (locale == currentLocale)
        ? Icon(Icons.check, color: Colors.blue)
        : Icon(null);
  }

  void changeLanguage(String locale) {
    setState(() {
      Settings().setValue('language',locale);
    });
  }
}