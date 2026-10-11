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
  Future<List<Activity>> loadItems(params,{refresh = false}) async {
    final entries = (params as Map).entries
        .map((entry) => MapEntry(entry.key.toString(), entry.value))
        .toList()..sort((a, b) => a.key.compareTo(b.key));
    final sortedParams = <String, dynamic>{for (final entry in entries) entry.key: entry.value};
    final filename = 'activities_${md5.convert(utf8.encode(jsonEncode(sortedParams)))}';
    final storage = getFileStorage();
    final cached = await storage.read(filename, expiration: 30);
    if (cached is List && !refresh) {
      _data = cached.map((data) => Activity.fromJson(Map<String, dynamic>.from(data))).toList();
      return _data!;
    }

    try {
      final remote = await _apiClient.loadActivities(sortedParams);
      _data = remote;
      await storage.write(remote, filename);
      notifyListeners();
      return remote;
    } catch (_) {
      final stale = cached is List ? cached : await storage.read(filename);
      if (stale is List) {
        _data = stale.map((data) => Activity.fromJson(Map<String, dynamic>.from(data))).toList();
        return _data!;
      }
      rethrow;
    }

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

    final key = "activity_${activityId}_user_${user.id}";
    try {
      final remoteActivityData = await _apiClient.getActivityDetails(activityId, user);
      await getFileStorage().write(remoteActivityData, key);
      return remoteActivityData;
    } catch (_) {
      final stale = await getFileStorage().read(key);
      if (stale != false) return stale;
      rethrow;
    }

  }
}
