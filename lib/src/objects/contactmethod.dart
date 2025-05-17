class ContactMethod {
  int? id;
  String? type;
  bool? verified;
  bool? isprimary;
  String? address;


  ContactMethod({this.id, this.type, this.verified, this.isprimary, this.address});

  factory ContactMethod.fromJson(Map<String, dynamic> responseData) {

    return ContactMethod(
      id: int.parse(responseData['id'].toString()),
      type: responseData['type'],
      verified: int.parse(responseData['verified']) == 1? true : false,
      isprimary: responseData['isprimary']!=null ?( int.parse(responseData['isprimary']) ==1  ? true : false) : false,
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

  @override
  String toString() {
    return 'ContactMethod{id: $id, type: $type, verified: $verified, isprimary: $isprimary, address: $address}';
  }
}

