
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
  int? awardedScore;
  int? availableScore;
  Map<String,dynamic>? data;
  Map<String,dynamic>? currentStation;
  Map<String, dynamic>? benefits;

  factory User.fromJson(Map<String, dynamic> responseData) {
    //print("Current station for user: "+responseData['currentstation']['objectid'].toString());

    return User(
      id: responseData['id'] is int ? responseData['id'] : int.parse(responseData['id']),
      firstname: responseData['firstname'],
      lastname: responseData['lastname'],
      email: responseData['email'],
      phone: responseData['phone'],
      type: responseData['type'],
      token: responseData['access_token'],
      renewalToken: responseData['renewal_token'],
      qrcode: responseData['qrcode'],
      image: responseData['image'],
      awardedScore: responseData['awardedscore'],
      availableScore: responseData['availablescore']!=null ?  (responseData['availablescore']  is int ? responseData['availablescore'] : int.parse(responseData['availablescore'])) : 0,
      currentStation: responseData['currentstation'] is String ? {'objectid':responseData['currentstation']} : responseData['currentstation'],
      data: responseData
    );

  }
  int? getCurrentStation()
  {
    if(this.currentStation != null)
      if (this.currentStation!.isNotEmpty) {
        // print('returning station '+this.currentStation!["objectid"]);
        return int.parse(this.currentStation!["objectid"]);
      } else {
        return null;
      }
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
    'awardedscore' : awardedScore,
    'availablescore' : availableScore,
    'renewalToken': renewalToken,
    'currentStation': currentStation,
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
    this.awardedScore,
    this.availableScore,
    this.currentStation,
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
              qrcode == other.qrcode &&
              awardedScore == other.awardedScore &&
              availableScore == other.availableScore &&
              currentStation == other.currentStation);

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
      qrcode.hashCode ^
      awardedScore.hashCode ^
      availableScore.hashCode ^
      currentStation.hashCode;

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
        ' awardedScore: $awardedScore,' +
        ' availableScore: $availableScore,' +
        ' currentStation: $currentStation,' +
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
      awardedScore:  awardedScore ?? this.awardedScore,
      availableScore: availableScore ?? this.availableScore,
      currentStation: currentStation ?? this.currentStation,
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
      'awardedScore': this.awardedScore,
      'availableScore': this.availableScore,
      'currentStation': this.currentStation,
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
      awardedScore: map['awardedScore'] as int,
      availableScore: map['availableScore'] as int,
      currentStation: map['currentStation'] as Map<String, dynamic>,
      data: map['data'] as Map<String,dynamic>,
    );
  }

//</editor-fold>
}


