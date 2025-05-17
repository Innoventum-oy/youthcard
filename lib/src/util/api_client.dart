import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:youth_card/src/objects/activityvisit.dart';
import 'package:youth_card/src/objects/form.dart';
import 'package:youth_card/src/objects/formcategory.dart';
import 'package:youth_card/src/objects/formelement.dart';
import 'package:youth_card/src/objects/webpage.dart';
import 'package:youth_card/src/util/app_url.dart';
import 'package:youth_card/src/objects/activityclass.dart';
import 'package:youth_card/src/objects/activity.dart';
import 'package:youth_card/src/objects/activitydate.dart';
import 'package:youth_card/src/objects/image.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/objects/userbenefit.dart';
import 'package:youth_card/src/objects/contactmethod.dart';
import 'package:youth_card/src/util/shared_preference.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ApiClient {
  static final _client = ApiClient._internal();

  //final _http = HttpClient();
  ApiClient._internal();

  final String baseUrl = AppUrl.baseURL;
  bool isProcessing = false;

  factory ApiClient() => _client;

  /*
  * _postJson handles POST request and returns the json decoded data from server back to caller function
  */
  Future<dynamic> _postJson(Uri uri, Map<String, dynamic> data) async {
    this.isProcessing = true;
    Map softwareInfo = {
      'appName': '',
      'packageName': '',
      'version': '',
      'buildNumber': '',
    };
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      softwareInfo['appName'] = packageInfo.appName;
      softwareInfo['packageName'] = packageInfo.packageName;
      softwareInfo['version'] = packageInfo.version;
      softwareInfo['buildNumber'] = packageInfo.buildNumber;
    });
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'User-Agent': softwareInfo['appName'] +
          ' / ' +
          softwareInfo['version'] +
          ' ' +
          softwareInfo['buildNumber']
    };
    var request = new http.MultipartRequest("POST", uri);
    headers.forEach((k, v) {
      request.headers[k] = v;
    });


    data.forEach((key, value) async {
      if (value is File) {

        request.files.add(await http.MultipartFile.fromPath(key, value.path));
      } else {

        request.fields[key] = json.encode(value);
      }
    });

    http.Response response =
        await http.Response.fromStream(await request.send());
    this.isProcessing = false;
    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {

        try {
          Map<String, dynamic> responseData = json.decode(response.body);

          //print(responseData);
          return responseData;
        } catch (e) {

        }
      } else {
        if(kDebugMode){
          print('response body was empty for uri .' + uri.toString());
        }

        return false;
      }
    } else {

      if (response.body.isNotEmpty) {
        Map<String, dynamic> responseData = json.decode(response.body);
        //debug

        return (responseData);
      }
      return false;
    }
  }

  /*
  * _getJson handles request and returns the json decoded data from server back to caller function
  */
  Future<dynamic> _getJson(Uri uri) async {
    //debug

    this.isProcessing = true;
    //Create software version header
    Map softwareInfo = {
      'appName': '',
      'packageName': '',
      'version': '',
      'buildNumber': '',
    };

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      softwareInfo['appName'] = packageInfo.appName;
      softwareInfo['packageName'] = packageInfo.packageName;
      softwareInfo['version'] = packageInfo.version;
      softwareInfo['buildNumber'] = packageInfo.buildNumber;
    });
    String userAgent = softwareInfo['appName'] +
        ' / ' +
        softwareInfo['version'] +
        ' ' +
        softwareInfo['buildNumber'];
    Map<String, String> headers = {'User-Agent': userAgent};

    var response = await http.get(uri, headers: headers);
    //todo: better handling of statuscodes other than 200 or forwarding them to function calling _getJSON
    // print(response.statusCode);
    this.isProcessing = false;
    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        try {
          Map<String, dynamic> body = json.decode(response.body);
          return body;
        } on FormatException {

          return null;
        }


      } else {
        if(kDebugMode) {
          print('response body was empty for uri .' + uri.toString());
        }
        return false;
      }
    } else
      return false;
  }

  /* Save object data */
  Future<dynamic> saveObject(params, objectData) async {
    this.isProcessing = true;
    String baseUrl = await Settings().getServer();
    String? apikey = await Settings().getValue("anonymousapikey");
    if (!params.containsKey("api_key") || params["api_key"] == null) {
      //  print('no api_key provided in params: using anonymous apikey '+apikey+' for calling getDatalist');
      params["api_key"] = apikey;
    } else


    params['method'] = 'json';
    var url = Uri.https(baseUrl, 'api/dispatcher/common/', params);
    this.isProcessing = false;
    return _postJson(url, objectData).then((json) {
      return json == false ? [] : json;
    });
  }
  Future<Map<String, dynamic>> deleteUserAccount(User loggedInUser) async {
    final Map<String, dynamic> params = {
      'method': 'json',
      'action': 'deleteownuseraccount',
      'api_key': loggedInUser.token,

    };
    var url = Uri.https(baseUrl, 'api/dispatcher/registration/', params);

    return _getJson(url).then((json) {
      //   print(json);
      return json ?? false;
    });
  }
  /*
    * Get user contactmethods from server
    */
  Future<List<ContactMethod>> getContactMethods(User user) async {
    String baseUrl = await Settings().getServer();
    final Map<String, dynamic> params = {
      'method': 'json',
      'action': 'getcontactmethods',
      'userid': user.id.toString(),
      'api_key': user.token,
    };

    var url = Uri.https(baseUrl, AppUrl.getContactMethods, params);
    return _getJson(url).then((json) => json['data']).then((data) {
      if (data == null) return [];
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
      'method': 'json',
      'action': 'getverificationcode',
      'email': email
    };
    var url = Uri.https(baseUrl, AppUrl.requestValidationToken, params);
    return _getJson(url).then((json) {
      return json;
    });
  }

  /*
  * Send the received confirmation key, entered by user, back to server
  * on success returns singlepass for changing user password
  */

  Future<Map<String, dynamic>> sendConfirmationKey(
      {contact, code, userid}) async {
    String baseUrl = await Settings().getServer();
    final Map<String, dynamic> params = {
      'method': 'json',
      'action': 'verify',
      'field': contact,
      'contactmethodid': contact,
      'userid': userid,
      'code': code
    };
    var url = Uri.https(baseUrl, AppUrl.checkValidationToken, params);
    //   var response = _getJson(url) as Map<String, dynamic>;

    return _getJson(url).then((json) {
      // print(json);
      return json;
    });
  }

  /* Send user registration information (register.dart) to server
  * Required data: first name, last name, email or phone, password.
  * On success, returns user object.
  * returns status (success / error) + possible related message from server
   */
  Future<Map<String, dynamic>>? register(
      {required String firstname,
      required String lastname,
      String? phone,
      String? email,
      required String password,
      String? passwordConfirmation,
      String? registrationCode,
      String? guardianName,
      String? guardianPhone,}) async {
    final Map<String, dynamic> registrationData = {
      'user': {
        'firstname': firstname,
        'lastname': lastname,
        'phone': phone ?? false,
        'email': email,
        'password': password,
        'guardianname': guardianName ?? false,
        'guardianphone': guardianPhone ?? false,
        // 'password_confirmation': passwordConfirmation ?? false
      },
      'registrationcode': registrationCode ?? false
    };
    String baseUrl = await Settings().getServer();
    var url = Uri.https(baseUrl, AppUrl.registration);

    return _postJson(url, registrationData).then((json) {

      return json != null ? json : false;
    });
  }

  /*
  * Send new password and required singlepass to authorize password change to server
   */
  Future<Map<String, dynamic>> changePassword(
      {password, userid, singlepass}) async {
    String baseUrl = await Settings().getServer();
    final Map<String, dynamic> params = {
      'method': 'json',
      'action': 'setpassword',
      'singlepass': singlepass,
      'userid': userid,
      'password': password,
      'verification': password
    };

    var url = Uri.https(baseUrl, AppUrl.checkValidationToken, params);
    //   var response = _getJson(url) as Map<String, dynamic>;
    return _getJson(url).then((json) {
      return json;
    });
  }

  Future<dynamic> dispatcherRequest(
      String targetModule, Map<String, dynamic> params) async {
    params['method'] = 'json';
    String baseUrl = await Settings().getServer();
    String? apikey = await Settings().getValue("anonymousapikey");
    if (!params.containsKey("api_key")) params["api_key"] = apikey;

    var url = Uri.https(baseUrl, 'api/dispatcher/$targetModule/', params);

    return _getJson(url).then((data) {

      return data;
    });
  }

  /* Getdetails returns only the object data. To get also description, use getObject */
  Future<dynamic> getDetails(String objectType, int objectId, User loggedInUser,
      {fields}) async {
    String baseUrl = await Settings().getServer();
    String? apikey = loggedInUser.token != null
        ? loggedInUser.token
        : await Settings().getValue("anonymousapikey");

    var url =
        Uri.https(baseUrl, 'api/$objectType/$objectId', {'api_key': apikey});
    // Returns only
    return _getJson(url).then((json) => json['data']).then((data) {
      return data != null ? data.first : null;
    });
  }

  Future<dynamic> getObject(String objectType, int objectId, User loggedInUser,
      {fields}) async {
    String baseUrl = await Settings().getServer();
    String? apikey = loggedInUser.token != null
        ? loggedInUser.token
        : await Settings().getValue("anonymousapikey");

    var url =
        Uri.https(baseUrl, 'api/$objectType/$objectId', {'api_key': apikey});
    // Returns only
    return _getJson(url).then((data) {
      return data;
    });
  }

  Future<dynamic> getDataList(
      String datatype, Map<String, dynamic> params) async {
    String baseUrl = await Settings().getServer();
    String? apikey = await Settings().getValue("anonymousapikey");
    if (!params.containsKey("api_key") || params["api_key"] == null) {
      //  print('no api_key provided in params: using anonymous apikey '+apikey+' for calling getDatalist');
      params["api_key"] = apikey;
    }

    params['method'] = 'json';
    //debug: print params
    //  params.forEach((key, value) {print('$key = $value');});

    var url = Uri.https(baseUrl, 'api/$datatype/', params);

    return _getJson(url).then((json) {
      if (json == false) return [];
      //  print(json);

      return (json['data'] ?? []);
    });
  }

  /*
  * Load list of activities for the activitylist view
   */
  Future<List<ActivityClass>> loadActivityClasses(Map<String, dynamic> params) async {
    return getDataList('activityclass', params).then((data) {
      if (data == null) return [];
      return data
          .map<ActivityClass>((data) => ActivityClass.fromJson(data))
          .toList();
    });
  }

  /*
  * Load detailed activity information for the activity view
   */
  Future<dynamic> getActivityClassDetails(int id, User user) async {
    return this.getDetails('activityclass', id, user);
  }

  /*
  * Load list of activityvisits
   */
  Future<List<ActivityVisit>> loadActivityVisits(
      Map<String, dynamic> params) async {
    return getDataList('activityvisit', params).then((data) {
      if (data == null) return [];
      //print(data);
      return data
          .map<ActivityVisit>((data) => ActivityVisit.fromJson(data['data']))
          .toList();
    });
  }

  /*
  * Load detailed activityvisit information for selected activityvisit
   */
  Future<dynamic> getActivityVisitDetails(int id, User user) async {
    return this.getDetails('activityvisit', id, user);
  }

  /*
  * Load visit information for given activity + activitydate
   */
  Future<dynamic> loadActivityDateVisits(
      int activityId, ActivityDate date, user) async {
    String? apikey = (user.token == null)
        ? await Settings().getValue("anonymousapikey")
        : user.token;
    final Map<String, dynamic> params = {
      'method': 'json',
      'action': 'activitydatevisits',
      'activityid': activityId.toString(),
      'activitydateid': date.id.toString(),
      'api_key': apikey
    };
    return this.dispatcherRequest('activity', params).then((data) {

      Map<dynamic, String> returnData =
          Map<dynamic, String>.from(data['visits']);
      return returnData;
    });
  }

  /*
  * Load list of activities for the activitylist view
   */
  Future<List<Activity>> loadActivities(Map<String, dynamic> params) async {
    return getDataList('activity', params).then((data) {
      if (data == null) return [];
      return data.map<Activity>((data) => Activity.fromJson(data)).toList();
    });
  }

  /*
  * Load list of activitydates for selected activity
   */
  Future<List<ActivityDate>> loadActivitydates(
      Activity activity, User user) async {
    final Map<String, dynamic> params = {
      'method': 'json',
      'activityid': activity.id.toString(),
      'api_key': user.token != null
          ? user.token
          : await Settings().getValue("anonymousapikey")
    };

    return getDataList('activitydate', params).then((data) {
      if (data == null) return [];

      return data
          .map<ActivityDate>((data) => ActivityDate.fromJson(data))
          .toList();
    });
  }

  /*
  * Load list of users for selected activity
   */
  Future<List<User>> loadActivityUsers(int activityId, User user) async {
    String? apikey = (user.token == null)
        ? await Settings().getValue("anonymousapikey")
        : user.token;
    final Map<String, dynamic> params = {
      'action': 'activityuserlist',
      'activityid': activityId.toString(),
      'api_key': apikey
    };
    return this.dispatcherRequest('activity', params).then((data) {
      if (data == null || data['data'] == null) return [];
      return data['data'].map<User>((data) => User.fromJson(data)).toList();
    });
  }

  /*
  * Load detailed activity information for the activity view
   */
  Future<dynamic> getActivityDetails(int activityId, User user) async {
    return this.getDetails('activity', activityId, user);
  }

  /*
  * Load list of userbenefits
   */
  Future<List<UserBenefit>> loadUserBenefits(
      Map<String, dynamic> params) async {


    return this.dispatcherRequest('activity', params).then((data) {
      data = data['data'];
      if (data == null) return [];

      return data
          .map<UserBenefit>((data) => UserBenefit.fromJson(data))
          .toList();
    });
  }

  /*
  * Load detailed userbenefit information
   */
  Future<dynamic> getUserBenefitDetails(int benefitId, User user) async {
    return this.getDetails('userbenefit', benefitId, user);
  }

  /*
  * Load list of images with given parameters
   */
  Future<List<ImageObject>> loadImages(Map<String, dynamic> params) async {
    return getDataList('image', params).then((data) {
      if (data == null) return [];
      return data.map<Activity>((data) => ImageObject.fromJson(data)).toList();
    });
  }

  /*
  * Get image details based on image id
   */
  Future<dynamic> getImageDetails(int imageId, User user) async {
    return this.getDetails('image', imageId, user);
  }

  /*
  * Register current user for attending to activity
   */
  Future<Map<String, dynamic>> registerForActivity(activityId, User user,
      {visitstatus = 'registered'}) async {
    return updateActivityRegistration(
        activityId: activityId, user: user, visitStatus: visitstatus);
  }

  Future<Map<String, dynamic>> updateActivityRegistration(
      {int? activityId,
      String visitStatus = 'registered',
      User? visitor,
      required User user,
      ActivityDate? visitDate}) async {


    /* todo - positioning
  */
    Map<String, String> params = {
      'action': 'recordvisit',
      'method': 'json',
      'activityid': activityId!.toString(),
      'activitydate':
          visitDate?.id != null ? visitDate!.id.toString() : 'false',
      'userid': visitor != null ? visitor.id.toString() : user.id.toString(),
      'visitstatus': visitStatus,
      'api_key': user.token!

      //'latitude': _latitude.toString(),
      //  'longitude':  _longitude.toString()
    };
    String baseUrl = await Settings().getServer();
    var url = Uri.https(baseUrl, '/api/dispatcher/activity/', params);
    var response = await _getJson(url);

    return response;
  }

  /*
  * Load list of pages
   */
  Future<List<WebPage>> loadPages(Map<String, dynamic> params) async {
    return getDataList('page', params).then((data) {
      if (data == null) return [];

      return data.map<WebPage>((data) => WebPage.fromJson(data)).toList();
    });
  }

  Future<dynamic> getPageDetails(int id, User user) async {
    return this.getDetails('page', id, user);
  }

  Future<Map<String, dynamic>>? sendFeedback(
      Map<String, dynamic> params, Map<String, dynamic> data) async {
    String baseUrl = await Settings().getServer();
    params['get_page'] = 'common';
    var url = Uri.https(baseUrl, 'api/dispatcher/common/', params);

    return _postJson(url, data).then((json) {

      return json != null ? json : false;
    });
  }

/*
  * Load list of FormCategoriess
  */

  Future<List<FormCategory>> loadFormCategories(
      Map<String, dynamic> params) async {
    //  params['appid'] =appId;
    return getDataList('formcategory', params).then((data) {
      if (data == null) return [];
      return data
          .map<FormCategory>((data) => FormCategory.fromJson(data))
          .toList();
    });
  }

/*
  * Load detailed activity information for selected form
   */
  Future<dynamic> getFormCategoryDetails(int id, User user) async {
    return this.getDetails('formcategory', id, user);
  }

  Future<Map<String, dynamic>>? saveFormData(
      Map<String, dynamic> params, Map<String, dynamic> data) async {
    var url = Uri.https(baseUrl, 'api/dispatcher/forms/', params);

    return _postJson(url, data).then((json) {

      return json != null ? json : false;
    });
  }

  Future<Map<String, dynamic>>? loadFormData(
      Map<String, dynamic> params) async {
    var url = Uri.https(baseUrl, 'api/dispatcher/forms/', params);

    return _getJson(url).then((json) {

      return json != null ? json : false;
    });
  }

/*
  * Load list of Forms
  */

  Future<List<Form>> loadForms(Map<String, dynamic> params) async {

    return getDataList('form', params).then((data) {
      if (data == null) return [];
      return data.map<Form>((data) => Form.fromJson(data)).toList();
    });
  }

/*
  * Load detailed activity information for selected form
   */
  Future<dynamic> getFormDetails(int id, User user) async {
    return this.getDetails('form', id, user);
  }

/*
  * Load list of Forms
  */

  Future<List<FormElement>> loadFormElements(
      Map<String, dynamic> params) async {
    return getDataList('formelement', params).then((data) {
      if (data == null) return [];
      return data.map<Form>((data) => Form.fromJson(data)).toList();
    });
  }

/*
  * Load detailed activity information for selected form
   */
  Future<dynamic> getFormElementDetails(int id, User user) async {
    return this.getDetails('formelement', id, user);
  }

/*
  * Load list of elements of selected form
   */
  Future<List<FormElement>> getElements(Map<String, dynamic> params) async {
    params['action'] = 'getelements';

    return this.dispatcherRequest('forms', params).then((data) {
      if (data == null) return [];
      if (data['items'] == null) {
        return [];
      }
      return data['items']
          .map<FormElement>((data) => FormElement.fromJson(data))
          .toList();
    });
  }
}
