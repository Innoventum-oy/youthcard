import 'package:flutter/foundation.dart';
import 'package:youth_card/src/objects/contactmethod.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/providers/objectprovider.dart';
import 'package:youth_card/src/util/api_client.dart';

class UserProvider with ChangeNotifier {

  UserProvider({this.id});

  int? id;
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

  Future<User> loadUser(int userId, User loadingUser)
  async {
    dynamic userdata = await this.getDetails(userId,loadingUser);
    if(userdata!=null) {
      userdata['data']['id'] = userdata['id'];

      this.setUserSilent(User.fromJson(userdata['data']));
      await this.getUserBenefits(loadingUser);
      notifyListeners();
      print(this._user);
    }
    else this.clearUser();
    return this._user;
  }

  Future<dynamic> getDetails(int userId, user) {
    return _apiClient.getDetails('iuser', userId, user);
  }

  Future<void> refreshUser({String? fields}) async {
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
        attributes: userData['attributes']
        //   currentStation: userData['currentstation'] is String ? {'objectid':userData['currentstation']} : userData['currentstation'],

      );
      this.setUser(u);
    } catch (e, stack) {
      print(
          'refreshing user information returned error $e\n Stack trace:\n $stack');
    }
  }
  Future<void>getUserBenefits([User? loadingUser]) async {
    if (this.user.id == null) return;

    final Map<String, String> params = {
      'action': 'loaduserbenefits',
      'userid': this.user.id!.toString(),
      'api_key': loadingUser!=null ? (loadingUser.token ??'') : this.user.token ?? '',

    };
    UserBenefitProvider userBenefitProvider =
    UserBenefitProvider();
    try {
      var result = await userBenefitProvider.loadItems(params);

      this._user.userbenefits.addAll(result);
     // print(result.length.toString() + ' benefits currently loaded for user '+this.user.fullname+'!');
    }
    catch (e, stack) {
      print('loadItems returned error $e\n Stack trace:\n $stack');
      String errormessage = e.toString();
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

      notifyListeners();
      if(data==null) return [];
      print(data);
      if(data['data']==null) return [];
      return data['data']
          .map<ContactMethod>((data) => ContactMethod.fromJson(data))
          .toList();
    }));
  }
}