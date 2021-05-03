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
  Status _registeredInStatus = Status.NotRegistered;
  VerificationStatus _verificationStatus = VerificationStatus.CodeNotRequested;
  String? _contactMethodId;
  String? _userId;
  String? _singlePass;

  Status get loggedInStatus => _loggedInStatus;
  Status get registeredInStatus => _registeredInStatus;

  VerificationStatus get verificationStatus => _verificationStatus;
  String? get contactMethodId => _contactMethodId;
  String? get userId => _userId;
  String? get singlePass => _singlePass;

  void setContactMethodId(newId)
  {
    _contactMethodId = newId;
    notifyListeners();
  }
  void setUserId(newId)
  {
    print('userid set to '+newId);
    _userId = newId;
    notifyListeners();
  }

  void setSinglePass(pass)
  {

    _singlePass = pass;
    notifyListeners();
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    var result;

    final Map<String, dynamic> loginData = {
      'user': {
        'email': email,
        'password': password
      }
    };

    _loggedInStatus = Status.Authenticating;
    notifyListeners();

    Response response = await post(Uri.https(AppUrl.baseURL,AppUrl.login),
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
      if(response.body!="")
      print(response.body);
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
    print('logging out user');

    final Map<String, dynamic> logoutData = {
       'user': {
        'email': user.email,
        'id' : user.id
      }
    };
    //Send logout request to server
    Response response = await post(Uri.https(AppUrl.baseURL,AppUrl.logout),
      body: json.encode(logoutData),
      headers: {'Content-Type': 'application/json'},
    );

    //handle response
    if (response.statusCode == 200) {
      if(response.body.isNotEmpty) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print(responseData);
        User authUser = User.fromJson(responseData);
      }

      UserPreferences().removeUser();

      _loggedInStatus = Status.NotLoggedIn;
      notifyListeners();
      print('user logged out');

      return true;
      }
    print('logout response code was '+response.statusCode.toString());
    return false;

  }

  Future<Map<String, dynamic>>? register(String email, String password, String passwordConfirmation) async {

    final Map<String, dynamic> registrationData = {
      'user': {
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation
      }
    };
    return await post(Uri.https(AppUrl.baseURL,AppUrl.register),
        body: json.encode(registrationData),
        headers: {'Content-Type': 'application/json'})
        .then(onValue)
        .catchError(onError) as Map<String,dynamic>;
  }

  void cancellogin()
  {
    print('running auth.cancellogin');
    _loggedInStatus = Status.NotLoggedIn;
    notifyListeners();


  }

  void setVerificationStatus(newstatus)
  {
    _verificationStatus = newstatus;
    notifyListeners();
  }

  static Future<FutureOr> onValue(Response response) async {
    var result;
    final Map<String, dynamic> responseData = json.decode(response.body);

    print(response.statusCode);
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
    print("the error is $error.detail");

    return {'status': false, 'message': 'Unsuccessful Request', 'data': error};

  }

}