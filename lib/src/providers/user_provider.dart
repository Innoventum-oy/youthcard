import 'package:flutter/foundation.dart';
import 'package:youth_card/src/objects/contactmethod.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/providers/objectprovider.dart';
import 'package:youth_card/src/util/api_client.dart';

class UserProvider with ChangeNotifier {

  UserProvider({this.id});

  int? id;
  User _user = User();
  final ApiClient _apiClient = ApiClient();

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
    _user = User();
    notifyListeners();
  }

  Future<User> loadUser(int userId, User loadingUser)
  async {

    dynamic userdata = await getObject(userId,loadingUser);
    if(userdata!=null) {

      setUserSilent(User.fromJson(userdata['data'].first,description:userdata['description']));
      await getUserBenefits(loadingUser);
      await getContactMethods(loadingUser);
      notifyListeners();
      //print(this._user);
    }
    else {
      clearUser();
    }
    return _user;
  }
  Future<dynamic> getFields(int userId, user) {
    final Map<String, dynamic> params = {
      'method' : 'json',
      'action': 'getavailablefields',
      'userid': userId.toString(),
      'api_key': user!=null ? (user.token ??'') : this.user.token ?? '',
    };
    return _apiClient.dispatcherRequest('registration',params);
  }
  Future<dynamic> getObject(int userId, user) {
    return _apiClient.getObject('iuser', userId, user);
  }
  Future<dynamic> getDetails(int userId, user) {
    return _apiClient.getDetails('iuser', userId, user);
  }

  Future<void> refreshUser({String? fields}) async {

    try {
      User u = user;
      dynamic userData =
      await getDetails(u.id!, _user);


      // keep token
      userData = userData['data'];
      // userData['access_token'] = u.token;
      // userData['renewal_token'] = u.renewalToken;

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
      setUser(u);
    } catch (e) {

    }
  }
  Future<void>getUserBenefits([User? loadingUser]) async {
    if (user.id == null) return;

    final Map<String, String> params = {
      'action': 'loaduserbenefits',
      'userid': user.id!.toString(),
      'api_key': loadingUser!=null ? (loadingUser.token ??'') : user.token ?? '',

    };
    UserBenefitProvider userBenefitProvider =
    UserBenefitProvider();
    try {
      var result = await userBenefitProvider.loadItems(params);

      _user.userbenefits.addAll(result);
     // print(result.length.toString() + ' benefits currently loaded for user '+this.user.fullname+'!');
    }
    catch (e) {

    }
  }

  Future<void> getContactMethods([User? loadingUser]) async {

    if(user.id==null) return;

    final Map<String, dynamic> params = {
      'method' : 'json',
      'action': 'getcontactmethods',
      'userid': user.id!.toString(),
      'api_key': loadingUser!=null ? (loadingUser.token ??'') : user.token ?? '',
    };
    contacts =(await _apiClient.dispatcherRequest('registration',params).then((data) {

      notifyListeners();
      if(data==null) return [];

      if(data['data']==null) return [];
      return data['data']
          .map<ContactMethod>((data) => ContactMethod.fromJson(data))
          .toList();
    }));
  }
}