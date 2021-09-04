import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:youth_card/src/objects/webpage.dart';
import 'package:youth_card/src/util/app_url.dart';
import 'package:youth_card/src/objects/activityclass.dart';
import 'package:youth_card/src/objects/activity.dart';
import 'package:youth_card/src/objects/activitydate.dart';
import 'package:youth_card/src/objects/image.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/objects/userbenefit.dart';
import 'package:youth_card/src/objects/contactmethod.dart';
import 'package:youth_card/src/util/utils.dart';
import 'package:youth_card/src/util/shared_preference.dart';
import 'package:package_info/package_info.dart';

class ApiClient {

  static final _client = ApiClient._internal();
  //final _http = HttpClient();
  ApiClient._internal();




  factory ApiClient() => _client;

  /*
  * _postJson handles POST request and returns the json decoded data from server back to caller function
  */
  Future<dynamic> _postJson(Uri uri, Map<String, dynamic> data) async
  {
    //Create software version header
    Map softwareInfo = {};
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      softwareInfo['appName'] = packageInfo.appName;
      softwareInfo['packageName'] = packageInfo.packageName;
      softwareInfo['version'] = packageInfo.version;
      softwareInfo['buildNumber'] = packageInfo.buildNumber;
    });
    Map<String,String> headers= {
      'Content-Type': 'application/json',
      'User-Agent': softwareInfo['appName']+' / '+softwareInfo['version']+' '+softwareInfo['buildNumber']
    };

    print('calling (post) '+uri.toString());
    var response = await http.post(uri,
      body: json.encode(data),
      headers: headers,
    );
    if (response.statusCode == 200) {
      if(response.body.isNotEmpty) {
        Map<String, dynamic> responseData = json.decode(response.body);
       //debug
       // print(responseData);
        return responseData;
      }
      else{
        print('response body was empty');
        return false;
      }

    }
    else{
    //  print(response.statusCode);
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
    //debug
    print('calling '+uri.toString());

  //Create software version header
  Map softwareInfo = {
    'appName': '',
    'packageName':'',
    'version':'',
    'buildNumber' :'',

  };
  PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
    softwareInfo['appName'] = packageInfo.appName;
    softwareInfo['packageName'] = packageInfo.packageName;
    softwareInfo['version'] = packageInfo.version;
    softwareInfo['buildNumber'] = packageInfo.buildNumber;
  });
  String userAgent = softwareInfo['appName']+' / '+softwareInfo['version']+' '+softwareInfo['buildNumber'];
  Map<String,String> headers= {
    'User-Agent': userAgent
  };

    var response = await http.get(uri,headers:headers);
   // print(response.statusCode);
    if(response.statusCode==200) {
      if(response.body!=null && response.body.isNotEmpty) {
        //print(response.body);
        Map<String, dynamic> body = json.decode(response.body);
       /* print('GETJSON DATA RECEIVED:');
        body.forEach((key, value) {
          if (key != 'data') print('$key = $value');
        });
        print('END GETJSON');
*/

        return (body);
      }
      else {
        print('response body was empty for uri .'+uri.toString());
        return false;
      }
    }
    else return false;

  }

  /*
    * Get user contactmethods from server
    */
  Future<List<ContactMethod>> getContactMethods(User user) async {

    String baseUrl = await Settings().getServer();
    final Map<String, dynamic> params = {
      'method' : 'json',
      'action': 'getcontactmethods',
      'userid': user.id.toString(),
      'api_key':user.token,
      'api_key':user.token,
    };

    var url = Uri.https(baseUrl, AppUrl.getContactMethods,params);
    return _getJson(url).then((json) => json['data']).then((data) {
      if(data==null) return [];
      return data
          .map<ContactMethod>((data) => ContactMethod.fromJson(data))
          .toList();
    });
  }

    /*
    * Request verificationcode / confirmation key from server
    */
    Future<Map<String, dynamic>> getConfirmationKey(String email) async {
     // print( 'requesting getverificationcode for '+email);
      String baseUrl = await Settings().getServer();
      final Map<String, dynamic> params = {
        'method' : 'json',
        'action': 'getverificationcode',
        'email': email
      };
      var url = Uri.https(baseUrl, AppUrl.requestValidationToken,params);
      return _getJson(url).then((json){
        return json;
      });
  }

  /*
  * Send the received confirmation key, entered by user, back to server
  * on success returns singlepass for changing user password
  */

  Future<Map<String, dynamic>> sendConfirmationKey({contact,code,userid}) async {
    String baseUrl = await Settings().getServer();
    final Map<String, dynamic> params = {
      'method' : 'json',
      'action': 'verify',
      'field': contact,
      'contactmethodid': contact,
      'userid' : userid,
      'code': code
    };
    var url = Uri.https(baseUrl, AppUrl.checkValidationToken,params);
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
    String baseUrl = await Settings().getServer();
    var url = Uri.https(baseUrl,AppUrl.registration);

    return _postJson(url,registrationData).then((json){
      // print(json);
      return json!=null ? json : false;
    });
  }

  /*
  * Send new password and required singlepass to authorize password change to server
   */
  Future<Map<String, dynamic>> changePassword({password,userid,singlepass}) async {
    String baseUrl = await Settings().getServer();
    final Map<String, dynamic> params = {
      'method' : 'json',
      'action': 'setpassword',
      'singlepass':singlepass,
      'userid' : userid,
      'password': password,
      'verification' : password
    };
   //params.forEach((key, value) {print('$key = $value');});
    var url = Uri.https(baseUrl, AppUrl.checkValidationToken,params);
    //   var response = _getJson(url) as Map<String, dynamic>;
    return _getJson(url).then((json){
      return json;

    });

  }

  Future<dynamic> dispatcherRequest(String targetModule,Map<String,dynamic> params) async {
    params['method'] ='json';
    String baseUrl = await Settings().getServer();
    String? apikey = await Settings().getValue("anonymousapikey") ;
    if(!params.containsKey("api_key") && apikey!=null)
      params["api_key"] = apikey;

    var url = Uri.https(baseUrl, 'api/dispatcher/$targetModule/', params);

    return _getJson(url).then((data)  {
      //  print(data);
      return data;
    });

  }

  Future<dynamic> getDetails(String objectType,int objectId,User loggedInUser,{fields:null}) async{
    String baseUrl = await Settings().getServer();
    String? apikey = loggedInUser.token!=null ? loggedInUser.token : await Settings().getValue("anonymousapikey") ;
    print('calling getDetails with apikey '+( apikey?? ' not set'));
    var url = Uri.https(baseUrl, 'api/$objectType/$objectId', { 'api_key':apikey});

    return _getJson(url).then((json) => json['data']).then((data) {

      return data.first;
    });
  }

  Future<dynamic> getDataList(String datatype,Map<String,dynamic> params) async {
    String baseUrl = await Settings().getServer();
    String? apikey = await Settings().getValue("anonymousapikey") ;
    if(!params.containsKey("api_key") && apikey!=null) {
      print('using anonymous apikey for getDatalist');
      params["api_key"] = apikey;
    }
    else print('using user datakey '+params['api_key'].toString());

    params['method'] = 'json';
    //debug: print params
    params.forEach((key, value) {print('$key = $value');});

    var url = Uri.https(baseUrl, 'api/$datatype/', params);

    return _getJson(url).then((json) {
      if(json==false) return [];
    //  print(json);
      return(json['data']?? []);

    });

  }

  /*
  * Load list of activities for the activitylist view
   */
  Future<List<ActivityClass>> loadActivityClasses(Map<String,dynamic> params) async {

    return getDataList('activityclass',params).then((data) {
      if(data==null) return [];
      return data
          .map<ActivityClass>((data) => ActivityClass.fromJson(data))
          .toList();
    });

  }

  /*
  * Load detailed activity information for the activity view
   */
  Future<dynamic> getActivityClassDetails(int id, User user) async {

    return this.getDetails('activityclass',id,user);
    String baseUrl = await Settings().getServer();
    String? apikey = (user.token==null) ? await Settings().getValue("anonymousapikey") : user.token;

    var url = Uri.https(baseUrl, 'api/activityclass/$id', { 'api_key': apikey});

    return _getJson(url).then((json) => json['data']).then((data) {
      // print(data);
      return data;
    });

  }

  /*
  * Load list of activities for the activitylist view
   */
  Future<List<Activity>> loadActivities(Map<String,dynamic> params) async {

    return getDataList('activity',params).then((data) {
      if(data==null) return [];
      return data
        .map<Activity>((data) => Activity.fromJson(data))
        .toList();
      });

  }

  /*
  * Load list of activitydates for selected activity
   */
  Future<List<ActivityDate>> loadActivitydates(Activity activity, User user) async {

    final Map<String, dynamic> params = {
      'method' : 'json',
      'activityid' : activity.id.toString(),
      'api_key' : user.token!=null ? user.token : await Settings().getValue("anonymousapikey")
    };

    return getDataList('activitydate',params).then((data) {
      if(data==null) return [];
      print(data);
      return data
          .map<ActivityDate>((data) => ActivityDate.fromJson(data))
          .toList();
    });

  }

  /*
  * Load list of users for selected activity
   */
  Future<List<User>> loadActivityUsers(int activityId, User user) async {

    String? apikey = (user.token==null) ? await Settings().getValue("anonymousapikey") : user.token;
    final Map<String, dynamic> params = {
      'action' : 'activityuserlist',
      'activityid' : activityId.toString(),
      'api_key': apikey
    };
    return this.dispatcherRequest('activity',params).then((data) {
      if(data==null) return [];
      print(data);
      return data
          .map<User>((data) => User.fromJson(data))
          .toList();
    });

  }

  /*
  * Load visit information for given activity + activitydate
   */
  Future<dynamic> loadActivityVisits(int activityId, ActivityDate date,user) async {

    String? apikey = (user.token==null) ? await Settings().getValue("anonymousapikey") : user.token;
    final Map<String, dynamic> params = {
      'method' : 'json',
      'action' : 'activitydatevisits',
      'activityid' : activityId.toString(),
      'activitydateid' : date.id.toString(),
      'api_key': apikey

    };
    return this.dispatcherRequest('activity',params).then((data) {
       print(data);
       Map <dynamic,String> returnData = Map<dynamic,String>.from(data);
       return returnData;

    });

  }

  /*
  * Load detailed activity information for the activity view
   */
  Future<dynamic> getActivityDetails(int activityId, User user) async {
    return this.getDetails('activity',activityId,user);

  }

  /*
  * Load list of userbenefits
   */
  Future<List<UserBenefit>> loadUserBenefits(Map<String,dynamic> params) async {
    //debug: print params

    return this.dispatcherRequest('activity',params).then((data) {
      data = data['data'];
      if(data==null) return [];
      print(data);
      return data
          .map<UserBenefit>((data) => UserBenefit.fromJson(data))
          .toList();
    });

    params.forEach((key, value) {print('$key = $value');});
    String baseUrl = await Settings().getServer();
    var url = Uri.https(baseUrl, '/api/dispatcher/activity/',
        params);
    return _getJson(url).then((json){ if(json==null || json == false) return [];
    var data = json['data'];
    if(data==null) return [];
      return data
          .map<UserBenefit>((data) => UserBenefit.fromJson(data))
          .toList();
    });

  }

  /*
  * Load detailed userbenefit information
   */
  Future<dynamic> getUserBenefitDetails(int benefitId, User user) async {
    return this.getDetails('userbenefit',benefitId,user);
  }

  /*
  * Load list of images with given parameters
   */
  Future<List<ImageObject>> loadImages(Map<String,dynamic> params) async {
    return getDataList('image',params).then((data) {
      if(data==null) return [];
      return data
          .map<Activity>((data) => ImageObject.fromJson(data))
          .toList();

    });

  }

  /*
  * Get image details based on image id
   */
  Future<dynamic> getImageDetails(int imageId, User user) async {
    return this.getDetails('image',imageId,user);
  }

  /*
  * Register current user for attending to activity
   */
  Future<Map<String,dynamic>> registerForActivity(activityId,User user,{visitstatus:'registered'}) async{

    return updateActivityRegistration(activityId:activityId,user:user,visitStatus: visitstatus);
  }
  Future<Map<String,dynamic>> updateActivityRegistration({int? activityId, String visitStatus:'registered',User? visitor,required User user,ActivityDate? visitDate}) async
  {

    print('Updating activityvisit for activity #'+activityId.toString()+': '+visitStatus);
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
      'method' : 'json',
      'activityid': activityId!.toString(),
      'activitydate' : visitDate?.id !=null ? visitDate!.id.toString() : 'false',
      'userid': visitor!=null ? visitor.id.toString() : user.id.toString(),
      'visitstatus': visitStatus,
      'api_key': user.token!

      //'latitude': _latitude.toString(),
      //  'longitude':  _longitude.toString()

    };
    String baseUrl = await Settings().getServer();
    var url = Uri.https(baseUrl, '/api/dispatcher/activity/', params);
    var response = await _getJson(url) ;

    if (response['message'].isNotEmpty)
      Notify(response['message']);
    return response;
  }
  /*
  * Load list of pages
   */
  Future<List<WebPage>> loadPages(Map<String,dynamic> params) async {

    return getDataList('page',params).then((data) {

      if(data==null) return [];

      return data
          .map<WebPage>((data) => WebPage.fromJson(data))
          .toList();
    });

  }
  Future<dynamic> getPageDetails(int id, User user) async {
    return this.getDetails('page',id,user);
  }

}
