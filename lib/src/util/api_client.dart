import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:youth_card/src/util/app_url.dart';
import 'package:youth_card/src/objects/activity.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/util/utils.dart';

class ApiClient {

  static final _client = ApiClient._internal();
  final _http = HttpClient();
  ApiClient._internal();

  final String baseUrl = AppUrl.baseURL;

  factory ApiClient() => _client;

  /*
  * _postJson handles POST request and returns the json decoded data from server back to caller function
  */
  Future<dynamic> _postJson(Uri uri, Map<String, dynamic> data) async
  {
    var response = await http.post(uri,
      body: json.encode(data),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      if(response.body.isNotEmpty) {
        Map<String, dynamic> responseData = json.decode(response.body);
       //debug
        print(responseData);
        return responseData;
      }
      else{
        print('response body was empty');
        return false;
      }

    }
    else{
      print(response.statusCode);
      if(response.body.isNotEmpty) {
        Map<String, dynamic> responseData = json.decode(response.body);
        //debug
        return(responseData);
      }
      return false;
    }

  }

  /*
  * _getJson handles request and returns the json decoded data from server back to caller function
  */
  Future<dynamic> _getJson(Uri uri) async {

    var response = await http.get(uri);
    print(response.statusCode);
    if(response.statusCode==200) {
      if(response.body.isNotEmpty) {
        print(response.body);
        Map<String, dynamic> body = json.decode(response.body);
        print('GETJSON DATA RECEIVED:');
        body.forEach((key, value) {
          if (key != 'data') print('$key = $value');
        });
        print('END GETJSON');


        return (body);
      }
      else {
        print('response body was empty.');
        return false;
      }
    }
    else return false;

  }

    /*
    * Request verificationcode / confirmation key from server
    */
    Future<Map<String, dynamic>> getConfirmationKey(String email) async {
     // print( 'requesting getverificationcode for '+email);
      final Map<String, dynamic> params = {
        'method' : 'json',
        'action': 'getverificationcode',
        'email': email
      };
      var url = Uri.https(AppUrl.baseURL, AppUrl.requestValidationToken,params);
      return _getJson(url).then((json){
        return json;
      });
  }

  /*
  * Send the received confirmation key, entered by user, back to server
  * on success returns singlepass for changing user password
  */
  Future<Map<String, dynamic>> sendConfirmationKey({contact,code,userid}) async {
    final Map<String, dynamic> params = {
      'method' : 'json',
      'action': 'verify',
      'field': contact,
      'contactmethodid': contact,
      'userid' : userid,
      'code': code
    };
    var url = Uri.https(AppUrl.baseURL, AppUrl.checkValidationToken,params);
    //   var response = _getJson(url) as Map<String, dynamic>;

    return _getJson(url).then((json){
     // print(json);
      return json;
    });
  }

  /* Send user registration information (register.dart) to server
  * Required data: first name, last name, email or phone, password.
  * On success, returns user object.
  * returns status (success / error) + possible related message from server
   */
  Future<Map<String, dynamic>>? register({required String firstname, required String lastname,String? phone,String? email, required String password, String? passwordConfirmation}) async {

    final Map<String, dynamic> registrationData = {
      'user': {
        'firstname' : firstname,
        'lastname' : lastname,
        'phone': phone ?? false,
        'email': email,
        'password': password,
       // 'password_confirmation': passwordConfirmation ?? false
      }
    };
    var url = Uri.https(AppUrl.baseURL,AppUrl.registration);

    return _postJson(url,registrationData).then((json){
       print(json);
      return json!=null ? json : false;
    });
  }

  /*
  * Send new password and required singlepass to authorize password change to server
   */
  Future<Map<String, dynamic>> changePassword({password,userid,singlepass}) async {

    final Map<String, dynamic> params = {
      'method' : 'json',
      'action': 'setpassword',
      'singlepass':singlepass,
      'userid' : userid,
      'password': password,
      'verification' : password
    };
   //params.forEach((key, value) {print('$key = $value');});
    var url = Uri.https(AppUrl.baseURL, AppUrl.checkValidationToken,params);
    //   var response = _getJson(url) as Map<String, dynamic>;
    return _getJson(url).then((json){
      return json;

    });

  }

  /*
  * Load list of activities for the activitylist view
   */
  Future<List<Activity>> loadActivities(Map<String,dynamic> params) async {
    //debug: print params
    params.forEach((key, value) {print('$key = $value');});
    var url = Uri.https(baseUrl, 'api/activity/',
        params);
    return _getJson(url).then((json) => json['data']).then((data) {
      if(data==null) return [];
      return data
        .map<Activity>((data) => Activity.fromJson(data))
        .toList();
      });

  }

  /*
  * Load detailed activity information for the activity view
   */
  Future<dynamic> getActivityDetails(int activityId, User user) async {
    var url = Uri.https(baseUrl, 'api/activity/$activityId', { 'api-key': user.token,'api_key':user.token});

    return _getJson(url).then((json) => json['data']).then((data) {
       // print(data);
        return data;
      });

  }

  /*
  * Get image details based on image id
   */
  Future<dynamic> getImageDetails(int imageId, User user) async {
    var url = Uri.https(baseUrl, 'api/image/$imageId', { 'api-key': user.token,'api_key':user.token});

    return _getJson(url);
  }

  /*
  * Register current user for attending to activity
   */
  Future<void> registerForActivity(activityId,User user) async{

    return updateActivityRegistration(activityId:activityId,user:user);
  }
  Future<dynamic> updateActivityRegistration({int? activityId, String visitStatus='registered',required User user}) async
  {
    Map map;
/* todo - positioning
    if(_currentPosition == null){
      Notify('Current position unknown, returning false from sendData. How to get the position first instead?');
      return "Error";
    }

    if(user== null){
      Notify('user is not set for updating registration, returning false. Why is user not set?');
      print(user);
      return "error";
    }
*/
    Map<String, String> params = {
      'action': 'recordvisit',
      'activityid': activityId!.toString(),
      'userid': user.id.toString(),
      'visitstatus': visitStatus,
      'api-key': user.token!,
      'api_key': user.token!
      //'latitude': _latitude.toString(),
      //  'longitude':  _longitude.toString()

    };

    var url = Uri.https(AppUrl.baseURL, '/api/dispatcher/activity/', params);
    var response = _getJson(url) as Map<String, dynamic>;

    if (response['message'].isNotEmpty)
      Notify(response['message']);
  }

}
