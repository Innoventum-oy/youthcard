
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

  User({this.id, this.firstname, this.lastname, this.email, this.phone, this.type, this.token, this.renewalToken,this.image,this.qrcode});

  factory User.fromJson(Map<String, dynamic> responseData) {
    return User(
        id: responseData['id'],
        firstname: responseData['firstname'],
        lastname: responseData['lastname'],
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

