import 'dart:async';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/objects/userbenefit.dart';
import 'package:youth_card/src/objects/activityclass.dart';
import 'package:youth_card/src/objects/activitydate.dart';
import 'package:youth_card/src/objects/activity.dart';
import 'package:youth_card/src/objects/image.dart';
import 'package:youth_card/src/util/api_client.dart';
import 'package:youth_card/src/util/local_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
abstract class ObjectProvider {
  User? user;

  Future<List<dynamic>> loadItems(params);

  Future<dynamic> getDetails(int itemId, user);
}

class ImageProvider extends ObjectProvider {
  ImageProvider();

  ApiClient _apiClient = ApiClient();

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

  ApiClient _apiClient = ApiClient();

  @override
  Future<List<UserBenefit>> loadItems(params) async {
    return _apiClient.loadUserBenefits(params);
  }

// returns json-decoded response
  @override
  Future<dynamic> getDetails(int benefitId, user,{reload:false}) {
    return _apiClient.getUserBenefitDetails(benefitId, user);
  }
}

class ActivityProvider extends ObjectProvider {
  ActivityProvider();

  ApiClient _apiClient = ApiClient();

  @override
  Future<List<Activity>> loadItems(params) async {
    print('Activityprovider loadItems called');
    String filename = md5.convert(utf8.encode(params.toString())).toString();
   // FileStorage.delete(filename);
    var activitydata = await FileStorage.read(filename,expiration: 30);
   /* (activitydata as Activity).map<Activity>((data) => Activity.fromJson(data))
        .toList();*/
    if (activitydata != false && activitydata.length>0)
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
      return activities;
      }
    else print('activitydata was false, loading remote results');

    final remoteactivitydata =  await _apiClient.loadActivities(params);
    FileStorage.write(remoteactivitydata,filename);
    print(remoteactivitydata);
    return remoteactivitydata;

  }

  @override
  Future<dynamic> getActivityDates(Activity activity, user) async{
    print('Activityprovider getActivityDates called');

    final remoteactivitydatedata =  await _apiClient.loadActivitydates(activity,user);

    return remoteactivitydatedata;
  }

  @override
  Future<dynamic> getActivityUsers(int activityId,user) async{
    final remoteactivityuserdata =  await _apiClient.loadActivityUsers(activityId,user);

    return remoteactivityuserdata;
  }
  @override
  Future<dynamic> getActivityDateVisits(int activityId,ActivityDate date,user) async{
    final remoteactivityvisitdata =  await _apiClient.loadActivityVisits(activityId,date,user);

    return remoteactivityvisitdata;
  }
  // returns json-decoded response
  @override
  Future<dynamic> getDetails(int activityId, user,{reload:false}) async {
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
