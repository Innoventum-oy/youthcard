class ContactMethod {
  int? id;
  String? type;
  bool? verified;
  bool? isprimary;
  String? address;


  ContactMethod({this.id, this.type, this.verified, this.isprimary, this.address});

  factory ContactMethod.fromJson(Map<String, dynamic> responseData) {

    //responseData.forEach((key, value) { print('$key = $value');});
    return ContactMethod(
      id: int.parse(responseData['id'].toString()),
      type: responseData['type'],
      verified: responseData['verified'],
      isprimary: responseData['isprimary'],
      address: responseData['address'],
    );
  }
  Map<String, dynamic> toJson() => {
    'id': id.toString(),
    'type': type,
    'verified': verified,
    'isprimary': isprimary,
    'address': address,

  };
}

