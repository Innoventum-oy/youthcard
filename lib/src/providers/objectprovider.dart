import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/util/api_client.dart';
export 'package:youth_card/src/util/api_client.dart';

abstract class ObjectProvider with ChangeNotifier {
  User _user = User();
  final ApiClient _apiClient = ApiClient();

  bool setUser(User user) {

    _user = user;
    // do it silent:  notifyListeners();
    return true;
  }

  User get user => _user;

  Future<List<dynamic>> loadItems(params);

  Future<dynamic> getDetails(int itemId, user);

  Future<dynamic> saveObject(Map params, Map objectData) async {
    return _apiClient.saveObject(params, objectData);
  }
}




