import 'package:youth_card/src/objects/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youth_card/src/util/app_url.dart';
import 'package:youth_card/src/util/local_storage.dart';
import 'dart:io';


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
    return FileStorage.write(user, this.filename);
  }

  Future<User> getUser() async {
    final userdata = await FileStorage.read(this.filename);
    return(userdata!=false ? User.fromJson(userdata) : User());
    }

  void removeUser() async {
    FileStorage.delete(this.filename);

  }
  Future<String> getToken(args) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token").toString();
    return token;
  }
}

class Settings{

  Future<String> getLanguage() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    //Intl.findSystemLocale();
    String systemLocale =  Platform.localeName; //Intl.getCurrentLocale();

    String language = prefs.getString('language') ?? systemLocale ;
   // print("Returning language " + language+ " - system locale is " + systemLocale);
    return language ;
  }
  Future<String> getServer() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String server = prefs.getString('server') ?? AppUrl.servers.values.first ;
   print("getServer returning " + server);
    return server ;
  }
  Future<bool> isServerSelected() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('servername')!=null && prefs.getString('servername')!.isNotEmpty ? true : false;

  }
  Future<String> getServerName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString('servername') ?? null;
    if(server==null) {
    //?? AppUrl.servers.keys.first ;
      String language = await this.getLanguage();
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

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString(arg).toString() ;
    //print('Settings.getvalue('+arg+') : '+token);
    return token;
  }
  Future<bool> setValue(String arg,dynamic val) async {
    print('storing '+arg+':'+val);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(arg,val);
    return true;
  }
}