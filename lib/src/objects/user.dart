
import 'package:youth_card/src/objects/userbenefit.dart';

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
  Map<String,dynamic>? data;
  List<UserBenefit> userbenefits = [];
  Map<String, dynamic>? benefits;

  factory User.fromJson(Map<String, dynamic> responseData) {
    //print("Current station for user: "+responseData['currentstation']['objectid'].toString());
  // responseData.forEach((key, value) { print('$key = $value');});
    return User(
      id: responseData['id'] is int ? responseData['id'] : int.parse(responseData['id']),
      firstname: responseData['firstname'],
      lastname: responseData['lastname'],
      email: responseData['email'],
      phone: responseData['phone'],
      type: responseData['type'],
      token: responseData['access_token']??responseData['token'],
      renewalToken: responseData['renewal_token'],
      qrcode: responseData['qrcode'],
      image: responseData['image'],
      data: responseData
    );

  }
  String get fullname => (this.firstname ?? '')+' '+(this.lastname??'');

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

    'data' : data,
  };

//<editor-fold desc="Data Methods">

  User({
    this.id,
    this.firstname,
    this.lastname,
    this.email,
    this.phone,
    this.type,
    this.token,
    this.renewalToken,
    this.image,
    this.qrcode,
    this.data,


  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is User &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              firstname == other.firstname &&
              lastname == other.lastname &&
              email == other.email &&
              phone == other.phone &&
              type == other.type &&
              token == other.token &&
              renewalToken == other.renewalToken &&
              image == other.image &&
              qrcode == other.qrcode

            );

  @override
  int get hashCode =>
      id.hashCode ^
      firstname.hashCode ^
      lastname.hashCode ^
      email.hashCode ^
      phone.hashCode ^
      type.hashCode ^
      token.hashCode ^
      renewalToken.hashCode ^
      image.hashCode ^
      qrcode.hashCode;


  @override
  String toString() {
    return 'User{' +
        ' id: $id,' +
        ' firstname: $firstname,' +
        ' lastname: $lastname,' +
        ' email: $email,' +
        ' phone: $phone,' +
        ' type: $type,' +
        ' token: $token,' +
        ' renewalToken: $renewalToken,' +
        ' image: $image,' +
        ' qrcode: $qrcode,' +


        '}';
  }

  User copyWith({
    int? id,
    String? firstname,
    String? lastname,
    String? email,
    String? phone,
    String? type,
    String? token,
    String? renewalToken,
    String? image,
    String? qrcode,
    int? awardedScore,
    int? availableScore,
    Map<String, dynamic>? currentStation,
    Map<String,dynamic>? attributes,
  }) {
    return User(
      id: id ?? this.id,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      type: type ?? this.type,
      token: token ?? this.token,
      renewalToken: renewalToken ?? this.renewalToken,
      image: image ?? this.image,
      qrcode: qrcode ?? this.qrcode,

     data: data ?? this.data,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'firstname': this.firstname,
      'lastname': this.lastname,
      'email': this.email,
      'phone': this.phone,
      'type': this.type,
      'token': this.token,
      'renewalToken': this.renewalToken,
      'image': this.image,
      'qrcode': this.qrcode,

      'attributes' : this.data,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int,
      firstname: map['firstname'] as String,
      lastname: map['lastname'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      type: map['type'] as String,
      token: map['token'] as String,
      renewalToken: map['renewalToken'] as String,
      image: map['image'] as String,
      qrcode: map['qrcode'] as String,

      data: map['data'] as Map<String,dynamic>,
    );
  }

//</editor-fold>
}


