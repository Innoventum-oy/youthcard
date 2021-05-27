import 'package:intl/intl.dart';

class Activity {
  int? id;
  String? name;
  String? description;
  DateTime? startdate;
  DateTime? enddate;
  DateTime? nexteventdate;
  String? address;
  String? postcode;
  String? city;
  String? latitude;
  String? longitude;
  Map<String, dynamic>? coverpicture;
  String? coverpictureurl;
  String? qrcode;
  int accesslevel;
  bool registration;

  Activity(
      {this.id,
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
      this.qrcode,
      this.registration = false,
      this.accesslevel = 0});

  factory Activity.fromJson(Map<String, dynamic> response) {
    DateTime formatFromString(String value) {
      DateTime val;
      try {
        //try this format
        val = DateFormat('dd.MM.yyyy HH:mm:ss').parse(value);
        return val;
      } catch (e) {
        try {
          val = DateFormat('yyyy-MM-dd HH:mm:ss').parse(value);
        } catch (e) {}
      }
      return DateTime.now();
    }

    // print (response);
    Map<String, dynamic> responseData = response['data'] ?? response;
    if (responseData['accesslevel'] !=
        null) if (int.parse(responseData['accesslevel']) > 10) {
      //print("Access to object {$responseData['objectid']}: " + responseData['accesslevel'].toString());
      //   responseData.forEach((key, value) { print('$key = $value');});
    }
    Map<String, dynamic> coverpicture;
    if (responseData['coverpicture'].runtimeType == String) {
      print('setting coverpicture from String to map');
      coverpicture = {'objectid': responseData['coverpicture']};
    } else {
      print('setting coverpicture to ' +
          responseData['coverpicture'].runtimeType.toString() +
          ': ' +
          responseData['coverpicture']);
      coverpicture = responseData['coverpicture'];
    }
    print('coverpicture: ' +
        coverpicture.runtimeType.toString() +
        ' : ' +
        coverpicture.toString());

    return Activity(
        id: responseData['objectid'] != null
            ? int.parse(responseData['objectid'])
            : null,
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
        address: responseData['address'],
        postcode: responseData['postcode'],
        city: responseData['city'],
        latitude: responseData['latitude'],
        longitude: responseData['longitude'],
        qrcode: responseData['qrcode'],
        coverpicture: coverpicture,
        coverpictureurl: responseData['coverpictureurl'],
        registration: responseData['registration'] == 'true' ||
                responseData['registration'] == true
            ? true
            : false,
        accesslevel: responseData['accesslevel'] is int
            ? responseData['accesslevel']
            : int.parse(responseData['accesslevel'] ??'0') );
  }

  Map toJson() => {
        'id': id.toString(),
        'name': name,
        'description': description,
        'startdate': startdate.toString(),
        'enddate': enddate.toString(),
        'nexteventdate': nexteventdate.toString(),
        'address': address,
        'postcode': postcode,
        'city': city,
        'latitude': latitude,
        'longitude': longitude,
        'qrcode': qrcode,
        'coverpicture': coverpicture,
        'coverpictureurl': coverpictureurl,
        'accesslevel': accesslevel
      };
}
