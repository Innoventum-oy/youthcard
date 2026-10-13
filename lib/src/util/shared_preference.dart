import 'package:youth_card/src/objects/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youth_card/src/util/app_url.dart';
import 'package:youth_card/src/util/local_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui' as ui;

import 'dart:async';

class EventLog{
  Future<bool> saveMessage(String message) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> currentContent = (prefs.getStringList('eventlog') ?? <String>[]);
    currentContent.add(message);
    prefs.setStringList('eventlog',currentContent);
    return true;
  }

  void clearLog() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.remove("eventlog");

  }

  Future<List<String>?> getMessages() async
  {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('eventlog');
  }

}

class UserPreferences {
  final filename = "local_user";

  Future<bool> saveUser(User user) async {
    return getFileStorage().write(user, filename);
  }

  Future<User> getUser() async {
    final userdata = await getFileStorage().read(filename);
    return(userdata!=false ? User.fromJson(userdata) : User());
    }

  Future<void> removeUser() async {
    await getFileStorage().delete(filename);

  }
  Future<String> getToken(args) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token").toString();
    return token;
  }
}

class Settings{
  Settings({bool? releaseMode}) : _releaseMode = releaseMode ??
      (kReleaseMode || const bool.fromEnvironment('STORE_SCREENSHOTS'));

  final bool _releaseMode;

  Future<String> getLanguage() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    //Intl.findSystemLocale();

    String systemLocale =  ui.PlatformDispatcher.instance.locale.toString();

    String language = prefs.getString('language') ?? systemLocale ;
   // print("Returning language " + language+ " - system locale is " + systemLocale);
    return language ;
  }
  Future<String> getServer() async {
    if (_releaseMode) return AppUrl.productionServerHost;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String server = prefs.getString('server') ?? AppUrl.servers.values.first ;

    return server ;
  }
  Future<bool> isServerSelected() async {
    if (_releaseMode) return true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('servername')!=null && prefs.getString('servername')!.isNotEmpty ? true : false;

  }
  Future<String> getServerName() async {
    if (_releaseMode) return AppUrl.productionServerName;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString('servername');
    if(server==null) {
    //?? AppUrl.servers.keys.first ;
      String language = await getLanguage();
      language = language.split('_')[0];
      if(AppUrl.serverToLanguageMapping.containsKey(language)) {
        server = AppUrl.serverToLanguageMapping[language] ??
            AppUrl.servers.keys.first;
        //print("getServerName returning " + server + " based on language $language");
      }
      else {
        server = AppUrl.servers.keys.first;
        //print("getServerName defaulting to " + server + " as first entry on the list because $language was not found in mapping");

      }
    }
  // else  print("getServerName returning " + server + " from prefs");
    return server;
  }
  Future<String> getValue(arg) async {
    if (_releaseMode && arg == 'anonymousapikey') {
      return AppUrl.anonymousApikeys[AppUrl.productionServerName]!;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString(arg).toString() ;
    //print('Settings.getvalue('+arg+') : '+token);
    return token;
  }
  Future<bool> setValue(String arg,dynamic val) async {
    // Check if arg is a string
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(arg,val);
    return true;
  }
  Future<void> clearValue(String arg) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(arg);
  }
}
