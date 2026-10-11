import 'package:intl/intl.dart';

class Activity {
  int? id;
  String? name;
  String? description;
  DateTime? startdate;
  DateTime? enddate;
  DateTime? nexteventdate;
  DateTime? registrationenddate;
  String? address;
  String? postcode;
  String? city;
  String? latitude;
  String? longitude;
  Map<String, dynamic>? coverpicture;
  String? coverpictureurl;
  int? activityClassId;
  String? activityType;
  String? qrcode;
  int accesslevel;
  int? maxvisitors;
  int? registeredvisitorcount;
  bool registration;

  Activity({
    this.id,
    this.name,
    this.description,
    this.startdate,
    this.enddate,
    this.nexteventdate,
    this.address,
    this.postcode,
    this.city,
    this.latitude,
    this.longitude,
    this.coverpicture,
    this.coverpictureurl,
    this.activityClassId,
    this.activityType,
    this.qrcode,
    this.maxvisitors,
    this.registeredvisitorcount,
    this.registrationenddate,
    this.registration = false,
    this.accesslevel = 0,
  });

  factory Activity.fromJson(Map<String, dynamic> response) {
    DateTime? formatFromString(String value) {
      if (value.isEmpty || value == 'null') return null;
      final iso = DateTime.tryParse(value);
      if (iso != null) return iso;
      try {
        //try this format
        return DateFormat('dd.MM.yyyy HH:mm:ss').parse(value);
      } catch (e) {
        try {
          return DateFormat('yyyy-MM-dd HH:mm:ss').parse(value);
        } catch (e) {}
      }
      return null;
    }

    Map<String, dynamic> responseData = response['data'] ?? response;
    final activityClass = responseData['activityclass'];
    final rawClassId = activityClass is Map
        ? activityClass['objectid'] ?? activityClass['id']
        : activityClass;

    Map<String, dynamic> coverpicture;
    if (responseData['coverpicture'].runtimeType == String) {
      coverpicture = {'objectid': responseData['coverpicture']};
    } else if (responseData['coverpicture'].runtimeType == int) {
      coverpicture = {'objectid': responseData['coverpicture'].toString()};
    } else if (responseData['coverpicture'] != null) {
      coverpicture = responseData['coverpicture'];
    } else {
      coverpicture = <String, dynamic>{};
    }

    return Activity(
      id: responseData['objectid'] != null
          ? int.parse(responseData['objectid'])
          : int.parse(responseData['id']),
      name: responseData['name'],
      description: responseData['description'],
      startdate: responseData['startdate'] != null
          ? formatFromString(responseData['startdate'])
          : null,
      enddate: responseData['enddate'] != null
          ? formatFromString(responseData['enddate'])
          : null,
      nexteventdate: responseData['nexteventdate'] != null
          ? formatFromString(responseData['nexteventdate'])
          : null,
      registrationenddate: responseData['registrationenddate'] != null
          ? formatFromString(responseData['registrationenddate'])
          : null,
      maxvisitors: responseData['maxvisitors'] is int
          ? responseData['maxvisitors']
          : (responseData['maxvisitors'] != null &&
                    responseData['maxvisitors'].length > 0
                ? int.parse(responseData['maxvisitors'])
                : null),
      registeredvisitorcount: responseData['registeredvisitorcount'] is int
          ? responseData['registeredvisitorcount']
          : (responseData['registeredvisitorcount'] != null &&
                    responseData['registeredvisitorcount'].length > 0
                ? int.parse(responseData['registeredvisitorcount'])
                : null),
      address: responseData['address'],
      postcode: responseData['postcode'],
      city: responseData['city'],
      latitude: responseData['latitude'],
      longitude: responseData['longitude'],
      qrcode: responseData['qrcode'],
      coverpicture: coverpicture,
      coverpictureurl: responseData['coverpictureurl'] is String
          ? responseData['coverpictureurl'] as String
          : null,
      activityClassId: int.tryParse(rawClassId?.toString() ?? ''),
      activityType: responseData['activitytype']?.toString(),
      registration:
          responseData['registration'] == 'true' ||
              responseData['registration'] == true
          ? true
          : false,
      accesslevel: responseData['accesslevel'] is int
          ? responseData['accesslevel']
          : int.parse(responseData['accesslevel'] ?? '0'),
    );
  }

  Map toJson() => {
    'id': id.toString(),
    'name': name,
    'description': description,
    'startdate': startdate?.toIso8601String(),
    'enddate': enddate?.toIso8601String(),
    'nexteventdate': nexteventdate?.toIso8601String(),
    'registrationenddate': registrationenddate?.toIso8601String(),
    'address': address,
    'postcode': postcode,
    'city': city,
    'latitude': latitude,
    'longitude': longitude,
    'qrcode': qrcode,
    'coverpicture': coverpicture,
    'coverpictureurl': coverpictureurl,
    'activityclass': activityClassId,
    'activitytype': activityType,
    'accesslevel': accesslevel,
    'registration': registration,
    'maxvisitors': maxvisitors,
    'registeredvisitorcount': registeredvisitorcount,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Activity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
