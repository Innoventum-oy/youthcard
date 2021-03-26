import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:youth_card/src/providers/objectprovider.dart' as objectmodel;
import 'package:youth_card/src/objects/image.dart';
class Activity {
  int id;
  String name;
  String description;
  DateTime startdate;
  DateTime enddate;
  String address;
  String postcode;
  String city;
  String latitude;
  String longitude;
  String coverpicture;
  String coverpictureurl;
  String qrcode;

  Activity({this.id, this.name, this.description, this.startdate, this.enddate, this.address, this.postcode,this.city,this.latitude,this.longitude,this.coverpicture,this.coverpictureurl,this.qrcode});



  factory Activity.fromJson(Map<String, dynamic> response) {
      Map<String, dynamic> responseData = response['data'];
      print(responseData);
      Map<String, dynamic> cover = responseData['coverpicture'];
    return Activity(
      id: int.parse(responseData['id']),
      name: responseData['name'],
      description: responseData['description'],
      startdate: DateFormat('dd.MM.yyyy HH:mm:ss').parse(responseData['startdate']) ,
      enddate: DateFormat('dd.MM.yyyy HH:mm:ss').parse(responseData['enddate']) ,
      address: responseData['address'],
      postcode: responseData['postcode'],
      city: responseData['city'],
      latitude: responseData['latitude'],
      longitude: responseData['longitude'],
      qrcode: responseData['qrcode'],
      coverpicture: cover == null ? 'default' : cover['objectid'],
      coverpictureurl: responseData['coverpictureurl'],
    );
  }

  Map toJson() => {
    'id' : id,
    'name': name,
    'description' : description,
    'startdate' : startdate,
    'enddate' : enddate,
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

