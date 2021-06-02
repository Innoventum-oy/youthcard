
import 'package:flutter/material.dart';

class User {
  int? id;
  String? firstname;
  String? lastname;
  String? email;
  String? phone;
  String? type;
  String? token;
  String? renewalToken;
  String? image;
  String? qrcode;
  Map<String, dynamic>? benefits;

  User({this.id, this.firstname, this.lastname, this.email, this.phone, this.type, this.token, this.renewalToken,this.image,this.qrcode});

  factory User.fromJson(Map<String, dynamic> responseData) {

      //print("Access to object {$responseData['objectid']}: " + responseData['accesslevel'].toString());
      responseData.forEach((key, value) { print('$key = $value');});
  print('setting acces token: '+(responseData['access_token']!=null ? responseData['access_token'] : responseData['token']));
    return User(
        id: int.parse(responseData['id'].toString()),
        firstname: responseData['firstname'],
        lastname: responseData['lastname'],
        email: responseData['email'],
        phone: responseData['phone'],
        type: responseData['type'],
        token: responseData['access_token']!=null ? responseData['access_token'] : responseData['token'],
        renewalToken: responseData['renewal_token'],
        qrcode: responseData['qrcode'],
        image: responseData['image'],
    );
  }
   Map<String, dynamic> toJson() => {
    'id': id.toString(),
    'firstname': firstname,
    'lastname': lastname,
    'email': email,
    'phone': phone,
    'type': type,
    'token': token,
    'image': image,
    'qrcode': qrcode,
    'renewalToken': renewalToken,
  };
}

