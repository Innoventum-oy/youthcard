import 'package:intl/intl.dart';

import '../objects/activity.dart';
import '../objects/activityvisit.dart';
import '../util/shared_preference.dart';
import 'objectprovider.dart';

class ActivityVisitListProvider extends ObjectProvider {

  ActivityVisitListProvider();

  List<ActivityVisit>? _data;
  List<ActivityVisit>? get list => _data;
  final ApiClient _apiClient = ApiClient();
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
    _data?.clear();

    DateTime now = DateTime.now();
    final Map<String, String> params = {
      'fields' :'id,startdate,enddate,userid,activityid,user,visitstatus,comment,interested,registered,cancelled',
      'activityid': activity.id.toString(),
      'api_key': user.token ?? await Settings().getValue("anonymousapikey"),
      'sort' : 'startdate DESC',
      'startdateFrom':  (loadParams['startdate'] ?? DateFormat('yyyy-MM-dd').format(now))
    };
    if(loadParams['enddate']!=null) params['startdateTo'] =loadParams['enddate'];
    _data = await _apiClient.loadActivityVisits(params);

    notifyListeners();
    return _data ;
  }

}