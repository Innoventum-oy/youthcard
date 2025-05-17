import 'package:intl/intl.dart';
import 'package:youth_card/src/providers/user_provider.dart';

enum VisitStatus{
  interested,
  registered,
  visited,
  cancelled
}

class ActivityVisit {
  int? id;
  int? userid;
  int? activityid;
  DateTime? startdate;
  DateTime? enddate;
  String? comment;
  String? visitstatus;
  DateTime? interested;
  DateTime? registered;
  DateTime? cancelled;
  UserProvider? userprovider = UserProvider();
  Map<String,dynamic>? data;

  ActivityVisit({
      this.id,
      this.userid,
      this.activityid,
      this.startdate,
      this.enddate,
      this.comment,
      this.visitstatus,
      this.interested,
      this.registered,
      this.cancelled,
      this.userprovider
  });

  Map<String, dynamic> toJson() {
    return {
      'id': this.id,
      'userid': this.userid,
      'activityid': this.activityid,
      'startdate': this.startdate,
      'enddate': this.enddate,
      'comment': this.comment,
      'visitstatus': this.visitstatus,
      'interested': this.interested,
      'registered': this.registered,
      'cancelled': this.cancelled,
      'userprovider' : this.userprovider,

    };
  }

  factory ActivityVisit.fromJson(Map<String, dynamic> map) {

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

    //map.forEach((key, value) { print('$key = $value');});
    return ActivityVisit(
      id: int.parse(map['id']),
      userid: map['userid']!=null ? int.parse(map['userid']) : null,
      activityid: map['activityid']!=null ? int.parse(map['activityid']) : null,
      startdate: map['startdate']!=null ? formatFromString(map['startdate']) : null,
      enddate: map['enddate'] != null ? formatFromString(map['enddate']) : null,
      comment: map['comment']!=null ? map['comment'] as String : null,
      visitstatus: map['visitstatus'],
      interested: map['interested'] != null ? formatFromString(map['interested']) :null,
      registered: map['registered'] != null ? formatFromString(map['registered']) : null,
      cancelled: map['cancelled'] != null ? formatFromString(map['cancelled']) : null,
      //user: map['user'] !=null ? User.fromJson(map['user']) : null,
      userprovider: UserProvider(id:map['userid']!=null ? int.parse(map['userid']) : null),
    );
  }
}