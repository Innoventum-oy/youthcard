import 'package:youth_card/src/objects/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youth_card/src/util/app_url.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

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


    final file = File('${(await getApplicationDocumentsDirectory()).path}/$this.filename.json');
    file.writeAsString(jsonEncode(user));

    print(user.renewalToken);

    return true;
  }

  Future<User> getUser() async {
    final file = File('${(await getApplicationDocumentsDirectory()).path}/$this.filename.json');
    if(await file.exists()) {
      print('returning user from local storage');

      return User.fromJson(jsonDecode(await file.readAsString()));
      }
    return User();
  }

  void removeUser() async {
     final file =  File('${(await getApplicationDocumentsDirectory()).path}/$this.filename.json');
     if(await file.exists()) {
       print('removing user from local storage');
       file.delete();
      }
  }

  Future<String> getToken(args) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token").toString();
    return token;
  }
}
class Settings{
  Future<String> getServer() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String server = prefs.getString('server') ?? AppUrl.servers.values.first ;

    return server ;
  }
  Future<String> getServerName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String server = prefs.getString('servername') ?? AppUrl.servers.keys.first ;

    return server  ;
  }
  Future<String> getValue(arg) async {
    print('retrieving '+arg);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString(arg).toString() ;
    return token;
  }
  Future<bool> setValue(String arg,dynamic val) async {
    print('storing '+arg+':'+val);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(arg,val);
    return true;
  }
}