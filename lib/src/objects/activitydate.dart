import 'package:intl/intl.dart';

class ActivityDate {
  int? id;
  int? activityid;
  DateTime? startdate;
  DateTime? enddate;

  ActivityDate(
  { this.id, this.activityid,this.startdate,this.enddate
  });
  factory ActivityDate.fromJson(Map<String, dynamic> response) {
    DateTime formatFromString(String value) {
      DateTime val;
      try {
        //try this format
        val = DateFormat('dd.MM.yyyy HH:mm:ss').parse(value);
        return val;
      } catch (e) {
        try {
          val = DateFormat('yyyy-MM-dd HH:mm:ss').parse(value);
          return val;
        } catch (e) {}
      }
      return DateTime.now();
    }
    Map<String, dynamic> responseData = response['data'] ?? response;
    return ActivityDate(
        id: responseData['objectid'] != null
        ? int.parse(responseData['objectid'])
        :  int.parse(responseData['id']),
        activityid : int.parse(responseData['activityid']),
        startdate: responseData['startdate'] != null
        ? formatFromString(responseData['startdate'])
            : null,
        enddate: responseData['enddate'] != null
        ? formatFromString(responseData['enddate'])
        : null,
    );
  }
}
