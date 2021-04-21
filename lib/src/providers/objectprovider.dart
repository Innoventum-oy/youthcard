import 'dart:async';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/objects/activity.dart';
import 'package:youth_card/src/objects/image.dart';
import 'package:youth_card/src/util/api_client.dart';

abstract class ObjectProvider{
  User? user;
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

  }
// returns json-decoded response
  @override
  Future<dynamic> getDetails(int activityId,user) {
    return _apiClient.getActivityDetails(activityId,user);
  }


}