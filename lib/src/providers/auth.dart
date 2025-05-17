import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'package:youth_card/src/objects/user.dart';

import 'package:youth_card/src/util/app_url.dart';
import 'package:youth_card/src/util/shared_preference.dart';



enum Status {
  NotLoggedIn,
  NotRegistered,
  LoggedIn,
  Registered,
  Authenticating,
  Registering,
  LoggedOut
}
enum VerificationStatus{
  CodeNotRequested,
  Validating,
  UserNotFound,
  CodeReceived,
  Verified,
  PasswordChanged

}
class AuthProvider with ChangeNotifier {

  Status _loggedInStatus = Status.NotLoggedIn;
  Status _registeredStatus = Status.NotRegistered;
  VerificationStatus _verificationStatus = VerificationStatus.CodeNotRequested;
  String? _contactMethodId;
  String? _userId;
  String? _singlePass;

  Status get loggedInStatus => _loggedInStatus;
  Status get registeredStatus => _registeredStatus;

  VerificationStatus get verificationStatus => _verificationStatus;
  String? get contactMethodId => _contactMethodId;
  String? get userId => _userId;
  String? get singlePass => _singlePass;

  void setRegisteredStatus(newStatus)
  {
    _registeredStatus = newStatus;
  }
  void setLoggedInStatus(newStatus)
  {
    _loggedInStatus = newStatus;
  }
  void setContactMethodId(newId)
  {
    _contactMethodId = newId;
    notifyListeners();
  }
  void setUserId(newId)
  {

    _userId = newId;
    notifyListeners();
  }

  void setSinglePass(pass)
  {

    _singlePass = pass;
    notifyListeners();
  }

  Future<Map<String, dynamic>> login(String email, String password,{String? server}) async {
    Map<String, dynamic> result;

    String baseUrl = server ?? await Settings().getServer();
    final Map<String, dynamic> loginData = {
      'user': {
        'email': email,
        'password': password
      }
    };

    _loggedInStatus = Status.Authenticating;
    notifyListeners();

    Response response = await post(Uri.https(baseUrl,AppUrl.login),
      body: json.encode(loginData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      var userData = responseData['data'];

      User authUser = User.fromJson(userData);

      UserPreferences().saveUser(authUser);

      _loggedInStatus = Status.LoggedIn;
      notifyListeners();

      result = {'status': true, 'message': 'Success', 'user': authUser};
    } else {

      _loggedInStatus = Status.NotLoggedIn;
      notifyListeners();
      result = {
        'status': false,
        'message': response.body!="" ? json.decode(response.body)['error'] : 'Login failed'
      };
    }
    return result;
  }

  // user logout method
  Future<bool> logout(User user) async {

    String baseUrl = await Settings().getServer();
    final Map<String, dynamic> logoutData = {
       'user': {
        'email': user.email,
        'id' : user.id
      }
    };
    //Send logout request to server
    Response response = await post(Uri.https(baseUrl,AppUrl.logout),
      body: json.encode(logoutData),
      headers: {'Content-Type': 'application/json'},
    );

    //handle response
    if (response.statusCode == 200) {
      /*if(response.body.isNotEmpty) {
        final Map<String, dynamic> responseData = json.decode(response.body);
       // print(responseData);
       // User authUser = User.fromJson(responseData);
      }*/
      setRegisteredStatus( Status.NotRegistered );
      UserPreferences().removeUser();

      _loggedInStatus = Status.NotLoggedIn;
      notifyListeners();

      return true;
      }

    return false;

  }


  void cancellogin()
  {

    _loggedInStatus = Status.NotLoggedIn;
    notifyListeners();


  }

  void setVerificationStatus(newstatus)
  {
    _verificationStatus = newstatus;
    notifyListeners();
  }

  static Future<FutureOr> onValue(Response response) async {
    Map<String, Object> result;
    final Map<String, dynamic> responseData = json.decode(response.body);

    //print(response.statusCode);
    if (response.statusCode == 200) {

      var userData = responseData['data'];

      User authUser = User.fromJson(userData);

      UserPreferences().saveUser(authUser);
      result = {
        'status': true,
        'message': 'Successfully registered',
        'data': authUser
      };
    } else {
//      if (response.statusCode == 401) Get.toNamed("/login");
      result = {
        'status': false,
        'message': 'Registration failed',
        'data': responseData
      };
    }

    return result;
  }

  static onError(error) {

    return {'status': false, 'message': 'Unsuccessful Request', 'data': error};

  }

}