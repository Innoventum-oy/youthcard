import 'dart:async';
import 'dart:convert';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/util/app_url.dart';
import 'package:youth_card/src/objects/activity.dart';
import 'package:youth_card/src/objects/image.dart';
import 'package:http/http.dart' as http;
import 'package:youth_card/src/util/api_client.dart';

abstract class ObjectProvider{
  User user;
  Future<List<Activity>> loadItems(params);
  Future<dynamic> getDetails(int itemId,user);

}

class ImageProvider extends ObjectProvider{
  ImageProvider();
  ApiClient _apiClient = ApiClient();

  @override
  Future<List<Activity>> loadItems(params) async {
    return _apiClient.loadActivities(params);
  }

  @override
  Future<dynamic> getDetails(int imageId, user) {
    return _apiClient.getImageDetails(imageId,user);
  }

}
class ActivityProvider extends ObjectProvider {
  ActivityProvider();
  ApiClient _apiClient = ApiClient();

  @override
  Future<List<Activity>> loadItems(params) async {
    return _apiClient.loadActivities(params);
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

  @override
  Future<dynamic> getDetails(int activityId,user) {
    return _apiClient.getActivityDetails(activityId,user);
  }


}