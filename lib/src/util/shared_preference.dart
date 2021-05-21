import 'package:youth_card/src/objects/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youth_card/src/util/app_url.dart';
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
  Future<bool> saveUser(User user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setInt("id", user.id!);
    prefs.setString("firstname", user.firstname ?? 'Unknown');
    prefs.setString("lastname", user.lastname ?? 'User' );
     prefs.setString("email", user.email ?? '');
    prefs.setString("phone",user.phone?.toString()??'');
    prefs.setString("type", user.type??'');
    prefs.setString("token", user.token??'');
    prefs.setString("renewalToken", user.renewalToken??'');
    prefs.setString("image", user.image??'');
    prefs.setString('qrcode',user.qrcode??'');

    print(user.renewalToken);

    return true;
  }

  Future<User> getUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    int? id = prefs.getInt("id");
    String? image = prefs.getString("image");
    String? qrcode = prefs.getString("qrcode");
    String? firstname = prefs.getString("firstname");
    String? lastname = prefs.getString("lastname");
    String? email = prefs.getString("email");
    String? phone = prefs.getString("phone");
    String? type = prefs.getString("type");
    String? token = prefs.getString("token");
    String? renewalToken = prefs.getString("renewalToken");

    return User(
        id: id,
        firstname: firstname,
        lastname: lastname,
        email: email,
        phone: phone,
        type: type,
        token: token,
        image : image,
        qrcode: qrcode,
        renewalToken: renewalToken);
  }

  void removeUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print('removing user from sharedpreferences');
    prefs.remove('id');
    prefs.remove('renewalToken');
    prefs.remove("firstname");
    prefs.remove("lastname");
    prefs.remove("email");
    prefs.remove("phone");
    prefs.remove("type");
    prefs.remove("token");
    prefs.remove('qrcode');
    prefs.remove('image');
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