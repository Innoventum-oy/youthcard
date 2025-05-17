import '../objects/activityclass.dart';
import 'objectprovider.dart';

class ActivityClassProvider extends ObjectProvider {
  ActivityClassProvider();

  final ApiClient _apiClient = ApiClient();

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