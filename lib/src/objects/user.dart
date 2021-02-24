
import 'package:flutter/material.dart';

class User {
  int id;
  String name;
  String email;
  String phone;
  String type;
  String token;
  String renewalToken;
  String image;
  String qrcode;

  User({this.id, this.name, this.email, this.phone, this.type, this.token, this.renewalToken,this.image,this.qrcode});

  factory User.fromJson(Map<String, dynamic> responseData) {
    return User(
        id: responseData['id'],
        name: responseData['name'],
        email: responseData['email'],
        phone: responseData['phone'],
        type: responseData['type'],
        token: responseData['access_token'],
        renewalToken: responseData['renewal_token'],
        qrcode: responseData['qrcode'],
        image: responseData['image'],
    );
  }
}

