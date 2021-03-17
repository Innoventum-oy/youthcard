import 'dart:async';
import 'dart:convert';
import 'dart:io';

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

class AuthProvider with ChangeNotifier {

  Status _loggedInStatus = Status.NotLoggedIn;
  Status _registeredInStatus = Status.NotRegistered;

  Status get loggedInStatus => _loggedInStatus;
  Status get registeredInStatus => _registeredInStatus;


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
      _loggedInStatus = Status.NotLoggedIn;
      notifyListeners();
      result = {
        'status': false,
        'message': json.decode(response.body)['error']
      };
    }
    return result;
  }
  // user logout method
  Future<Map<String, dynamic>> logout(User user) async {
    var result;

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
        'message': json.decode(response.body)['error']
      };
    }
    return result;

  }
  Future<Map<String, dynamic>> register(String email, String password, String passwordConfirmation) async {

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
        .catchError(onError);
  }
   void cancellogin()
  {
    print('running auth.cancellogin');
    _loggedInStatus = Status.NotLoggedIn;
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