import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:youth_card/src/providers/objectprovider.dart' as objectmodel;
import 'package:youth_card/src/objects/image.dart';
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
  String? coverpicture;
  String? coverpictureurl;
  String? qrcode;
  int accesslevel;
  bool registration;

  Activity({this.id, this.name, this.description, this.startdate, this.enddate, this.nexteventdate, this.address, this.postcode,this.city,this.latitude,this.longitude,this.coverpicture,this.coverpictureurl,this.qrcode,this.registration=false,this.accesslevel=0});



  factory Activity.fromJson(Map<String, dynamic> response) {

     Map<String, dynamic> responseData =  response['data'];
     // print('creating activity '+responseData['objectid'].toString()+' fromJSON');


      Map<String, dynamic>? cover = responseData['coverpicture'] ?? null;
      if(int.parse(responseData['accesslevel'])>10) {
        //print("Access to object {$responseData['objectid']}: " + responseData['accesslevel'].toString());
          responseData.forEach((key, value) { print('$key = $value');});
      }
        return Activity(
            id: responseData['objectid'] !=null ? int.parse(responseData['objectid']) : null,
            name: responseData['name'],
            description: responseData['description'],
            startdate: responseData['startdate']!=null ? DateFormat('dd.MM.yyyy HH:mm:ss').parse(responseData['startdate'])  : null,
            enddate: responseData['enddate']!=null ?DateFormat('dd.MM.yyyy HH:mm:ss').parse(responseData['enddate']) : null ,
            nexteventdate: responseData['nexteventdate']!=null ? DateFormat('yyyy-MM-dd HH:mm:ss').parse(responseData['nexteventdate']) :null ,
            address: responseData['address'],
            postcode: responseData['postcode'],
            city: responseData['city'],
            latitude: responseData['latitude'],
            longitude: responseData['longitude'],
            qrcode: responseData['qrcode'],
            coverpicture: cover == null ? 'default' : cover['objectid'],
            coverpictureurl: responseData['coverpictureurl'],
            registration: responseData['registration'] == 'true' || responseData['registration']==true ? true : false,
            accesslevel:  int.parse(responseData['accesslevel'])
        );
  }

  Map toJson() => {
    'id' : id,
    'name': name,
    'description' : description,
    'startdate' : startdate,
    'enddate' : enddate,
    'nexteventdate' : nexteventdate,
    'address' : address,
    'postcode' : postcode,
    'city' : city,
    'latitude' : latitude,
    'longitude': longitude,
    'qrcode': qrcode,
    'coverpicture':coverpicture,
    'coverpictureurl' : coverpictureurl,
  };
}

