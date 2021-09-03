import 'package:flutter/foundation.dart';
import 'package:youth_card/src/objects/contactmethod.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/providers/objectprovider.dart' as objectmodel;
import 'package:youth_card/src/util/api_client.dart';
class UserProvider with ChangeNotifier {
  UserProvider();

  User _user = new User();
  ApiClient _apiClient = ApiClient();

  User get user => _user;
  List<ContactMethod> contacts = [];
  List<ContactMethod> get contactMethods => contacts;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void setUserSilent(User user) {
    _user = user;
  }

  void clearUser() {
    _user = new User();
    notifyListeners();
  }


  Future<dynamic> getDetails(int userId, user) {
    return _apiClient.getDetails('iuser', userId, user);
  }

  Future<void> refreshUser({String? fields: null}) async {
    print('refreshing user information from server');
    try {
      User u = this.user;
      dynamic userData =
      await this.getDetails(u.id!, this._user);


      // keep token
      userData = userData['data'];
      // userData['access_token'] = u.token;
      // userData['renewal_token'] = u.renewalToken;
      print('user score: ' + userData['availablescore'].toString());
      u = u.copyWith(
        firstname: userData['firstname'],
        lastname: userData['lastname'],
        email: userData['email'],
        phone: userData['phone'],
        type: userData['type'],
        token: userData['access_token'],
        renewalToken: userData['renewal_token'],
        qrcode: userData['qrcode'],
        image: userData['image'],
        awardedScore: userData['awardedscore'],
        availableScore: userData['availablescore'],
        //   currentStation: userData['currentstation'] is String ? {'objectid':userData['currentstation']} : userData['currentstation'],

      );
      this.setUser(u);
    } catch (e, stack) {
      print(
          'refreshing user information returned error $e\n Stack trace:\n $stack');
    }
  }
  Future<void> getContactMethods() async {
    print('getContactMethods called for user provider');
    if(this.user.id==null) return;

    final Map<String, dynamic> params = {
      'method' : 'json',
      'action': 'getcontactmethods',
      'userid': this.user.id!.toString(),

      'api_key':this.user.token,
    };
    this.contacts =(await _apiClient.dispatcherRequest('registration',params).then((data) {

      // return _getJson(url).then((json) => json['data']).then((data) {
      if(data==null) return [];
      print(data);
      if(data['data']==null) return [];
      return data['data']
          .map<ContactMethod>((data) => ContactMethod.fromJson(data))
          .toList();
    }));
  }
}