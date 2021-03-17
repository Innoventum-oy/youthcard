import 'dart:async';
import 'dart:convert';
import 'package:youth_card/src/util/app_url.dart';
import 'package:youth_card/src/objects/activity.dart';
import 'package:http/http.dart' as http;
class ActivityLoader {
  Future<List<Activity>> loadActivities(params) async {
    var data = await http.get(Uri.https(
        AppUrl.baseURL, 'activity/'));
    var jsonData = json.decode(data.body);
    print('received data'+data.body);
    List<Activity> activityData = [];
    for (var a in jsonData) {
      Activity item = Activity.fromJson(jsonData);
      activityData.add(item);
    }
    print(activityData.length);
    return activityData;
  }
}