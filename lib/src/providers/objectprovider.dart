import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:youth_card/src/objects/activityvisit.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/objects/form.dart' as iCMSForm;
import 'package:youth_card/src/objects/formcategory.dart';
import 'package:youth_card/src/objects/formelement.dart';
import 'package:youth_card/src/objects/userbenefit.dart';
import 'package:youth_card/src/objects/activityclass.dart';
import 'package:youth_card/src/objects/activitydate.dart';
import 'package:youth_card/src/objects/activity.dart';
import 'package:youth_card/src/objects/image.dart';
import 'package:youth_card/src/util/api_client.dart';
import 'package:youth_card/src/util/local_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'package:youth_card/src/util/shared_preference.dart';

abstract class ObjectProvider with ChangeNotifier {
  User _user = new User();
  ApiClient _apiClient = ApiClient();

  bool setUser(User user) {
    print('user set for objectprovider to ' + user.lastname.toString() + ' ' +
        user.firstname.toString());
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

class ImageProvider extends ObjectProvider {
  ImageProvider();

  //ApiClient _apiClient = ApiClient();

  @override
  Future<List<ImageObject>> loadItems(params) async {
    return _apiClient.loadImages(params);
  }

  @override
  Future<dynamic> getDetails(int imageId, user) {
    return _apiClient.getImageDetails(imageId, user);
  }
}


class UserBenefitProvider extends ObjectProvider {
  UserBenefitProvider();

  //ApiClient _apiClient = ApiClient();

  @override
  Future<List<UserBenefit>> loadItems(params) async {
    return _apiClient.loadUserBenefits(params);
  }

// returns json-decoded response
  @override
  Future<dynamic> getDetails(int benefitId, user,{reload =false}) {
    return _apiClient.getUserBenefitDetails(benefitId, user);
  }
}

class ActivityVisitListProvider extends ObjectProvider {

  ActivityVisitListProvider();

  List<ActivityVisit>? _data;
  List<ActivityVisit>? get list => _data;

  @override
  Future<List<ActivityVisit>> loadItems(params) async {
    return _apiClient.loadActivityVisits(params);
  }

// returns json-decoded response
  @override
  Future<dynamic> getDetails(int id, user,{reload =false}) {
    return _apiClient.getActivityVisitDetails(id, user);
  }

  Future<List<ActivityVisit>?> loadActivityVisits(Activity activity,{loadParams}) async
  {
    this._data?.clear();
    print('loadVisits called for '+(activity.name ?? '')+' user:'+(this.user.fullname));

    DateTime now = DateTime.now();
    final Map<String, String> params = {
      'fields' :'id,startdate,enddate,userid,activityid,user,visitstatus,comment,interested,registered,cancelled',
      'activityid': activity.id.toString(),
      'api_key': this.user.token ?? await Settings().getValue("anonymousapikey"),
      'sort' : 'startdate DESC',
      'startdateFrom':  (loadParams['startdate'] ?? DateFormat('yyyy-MM-dd').format(now))
    };
    if(loadParams['enddate']!=null) params['startdateTo'] =loadParams['enddate'];
    this._data = await _apiClient.loadActivityVisits(params);
    print(this._data!.length.toString()+' activityvisits loaded');
    notifyListeners();
    return this._data ;
  }

}

class ActivityListProvider extends ObjectProvider {
  ActivityListProvider();


  List<Activity>? _data;

  List<Activity>? get list => _data;


/*
 * Load items for which user has ACL >= MODIFY

 */
  Future<void> loadMyItems() async
  {
    print('loadMyItems called for '+this.user.fullname);

    DateTime now = DateTime.now();
    final Map<String, String> params = {
      'accesslevel':'modify',
      'activitystatus': 'active',
      'api_key': this.user.token ?? await Settings().getValue("anonymousapikey"),
      'gte:startdate': DateFormat('yyyy-MM-dd').format(now),
      'grouping':'activity.id'
    };
     this._data = await this.loadItems(params,refresh:true);
  }


  @override
  Future<List<Activity>> loadItems(params,{refresh =false}) async {
    print('Activityprovider loadItems called');
    String filename = md5.convert(utf8.encode(params.toString())).toString();
   // FileStorage.delete(filename);
    var activitydata = await FileStorage.read(filename,expiration: 30);
   /* (activitydata as Activity).map<Activity>((data) => Activity.fromJson(data))
        .toList();*/
    if (activitydata != false && activitydata.length>0 && !refresh)
    {
     // print(activitydata);
      //@todo refresh
      print('Loaded activity list from local storage $filename');
      List <Activity> activities = [];

      for(var data in activitydata) {
        /*
        data.forEach((key,value){

          if(value!=null) print(key+': '+value.toString());
        });
      */
       // print(data.runtimeType.toString());
        Activity a = Activity.fromJson(data);
        activities.add(a);

          }
      //print('received '+activities.length.toString()+' activities from server');
      this._data = activities;
      return activities;
      }
    else print('activitydata was false (or refresh was requested), loading remote results');

    final remoteactivitydata =  await _apiClient.loadActivities(params);
    FileStorage.write(remoteactivitydata,filename);
    notifyListeners();
    return remoteactivitydata;

  }

  Future<dynamic> getActivityDates(Activity activity, user) async{
    print('Activityprovider getActivityDates called');

    final remoteactivitydatedata =  await _apiClient.loadActivitydates(activity,user);

    return remoteactivitydatedata;
  }


  Future<dynamic> getActivityUsers(int activityId,user) async{
    final remoteactivityuserdata =  await _apiClient.loadActivityUsers(activityId,user);

    return remoteactivityuserdata;
  }

  Future<dynamic> getActivityDateVisits(int activityId,ActivityDate date,user) async{
    final remoteactivityvisitdata =  await _apiClient.loadActivityDateVisits(activityId,date,user);

    return remoteactivityvisitdata;
  }

  // returns json-decoded response
  @override
  Future<dynamic> getDetails(int activityId, user,{reload =false}) async {
    print('getting activity details, reload is set to '+reload.toString());
   if(!reload) {
     final activitydata = await FileStorage.read(
         "activity_" + activityId.toString() + "_user_" + user.id.toString(),
         expiration: 30);
     if (activitydata != false) {
       //@todo refresh
       print(
           'Loaded activity details from local storage for activity ${activityId
               .toString()}');
       return activitydata;
     }
   }
    final remoteactivitydata = await _apiClient.getActivityDetails(activityId, user);
   print('writing received activitydata to local storage for #'+activityId.toString());
    FileStorage.write(remoteactivitydata,"activity_" + activityId.toString() + "_user_"+user.id.toString());
    return remoteactivitydata;

  }
}

class ActivityClassProvider extends ObjectProvider {
  ActivityClassProvider();
  ApiClient _apiClient = ApiClient();

  @override
  Future<List<ActivityClass>> loadItems(params) async {

    return _apiClient.loadActivityClasses(params);

  }
// returns json-decoded response
  @override
  Future<dynamic> getDetails(int activityClassId,user) {
    return _apiClient.getActivityClassDetails(activityClassId,user);
  }


}
class FormProvider extends ObjectProvider {
  FormProvider();
  ApiClient _apiClient = ApiClient();

  @override
  Future<List<iCMSForm.Form>> loadItems(params) async {

    return _apiClient.loadForms(params);

  }
// returns json-decoded response
  @override
  Future<dynamic> getDetails(int formId,user) {
    return _apiClient.getFormDetails(formId,user);
  }



}

class FormCategoryProvider extends ObjectProvider {
  FormCategoryProvider();
  ApiClient _apiClient = ApiClient();

  @override
  Future<List<FormCategory>> loadItems(params) async {

    return _apiClient.loadFormCategories(params);

  }
// returns json-decoded response
  @override
  Future<dynamic> getDetails(int id,user) {
    return _apiClient.getFormCategoryDetails(id,user);
  }
}
class FormElementProvider extends ObjectProvider {
  FormElementProvider();
  ApiClient _apiClient = ApiClient();

  @override
  Future<List<FormElement>> loadItems(params) async {

    return _apiClient.loadFormElements(params);

  }
  Future<List<FormElement>> getElements(params) async {

    return _apiClient.getElements(params);

  }
// returns json-decoded response
  @override
  Future<dynamic> getDetails(int id,user) {
    return _apiClient.getFormElementDetails(id,user);
  }

}
