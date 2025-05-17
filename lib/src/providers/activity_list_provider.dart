import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';

import '../objects/activity.dart';
import '../objects/activitydate.dart';
import '../util/local_storage.dart';
import '../util/shared_preference.dart';
import 'objectprovider.dart';

class ActivityListProvider extends ObjectProvider {

  ActivityListProvider();
  List<Activity>? _data;
  List<Activity>? get list => _data;
  final ApiClient _apiClient = ApiClient();
  Future<void> loadMyItems() async
  {
    DateTime now = DateTime.now();
    final Map<String, String> params = {
      'accesslevel':'modify',
      'activitystatus': 'active',
      'api_key': user.token ?? await Settings().getValue("anonymousapikey"),
      'gte:startdate': DateFormat('yyyy-MM-dd').format(now),
      'grouping':'activity.id'
    };
    _data = await loadItems(params,refresh:true);
  }


  @override
  Future<List<Activity>> loadItems(params,{refresh =false}) async {

    String filename = md5.convert(utf8.encode(params.toString())).toString();
    // FileStorage.delete(filename);
    var activitydata = await getFileStorage().read(filename,expiration: 30);
    /* (activitydata as Activity).map<Activity>((data) => Activity.fromJson(data))
        .toList();*/
    if (activitydata != false && activitydata.length>0 && !refresh)
    {

      List <Activity> activities = [];

      for(var data in activitydata) {

        Activity a = Activity.fromJson(data);
        activities.add(a);

      }

      _data = activities;
      return activities;
    }

    final remoteactivitydata =  await _apiClient.loadActivities(params);
    getFileStorage().write(remoteactivitydata,filename);
    notifyListeners();
    return remoteactivitydata;

  }

  Future<dynamic> getActivityDates(Activity activity, user) async{

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

    if(!reload) {
      final activitydata = await getFileStorage().read(
          "activity_${activityId}_user_${user.id}",
          expiration: 30);
      if (activitydata != false) {

        return activitydata;
      }
    }

    final remoteactivitydata = await _apiClient.getActivityDetails(activityId, user);

    getFileStorage().write(remoteactivitydata,"activity_${activityId}_user_${user.id}");
    return remoteactivitydata;

  }
}
