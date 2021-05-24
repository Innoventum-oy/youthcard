import 'package:flutter/foundation.dart';
import 'package:youth_card/src/objects/user.dart';

class UserProvider with ChangeNotifier {
  User _user = new User();

  User get user => _user;

  void setUser(User user) {

    _user = user;
   notifyListeners();
  }
  void setUserSilent(User user) {

    _user = user;

  }
  void clearUser(){
    _user = new User();
    notifyListeners();
  }
}