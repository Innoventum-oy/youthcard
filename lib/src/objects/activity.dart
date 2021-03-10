
class Activity {
  int id;
  String name;
  String description;
  String startdate;
  String enddate;
  String address;
  String postcode;
  String city;
  String latitude;
  String longitude;
  String coverpicture;
  String qrcode;

  Activity({this.id, this.name, this.description, this.startdate, this.enddate, this.address, this.postcode,this.city,this.latitude,this.longitude,this.coverpicture,this.qrcode});

  factory Activity.fromJson(Map<String, dynamic> responseData) {
    return Activity(
      id: responseData['id'],
      name: responseData['name'],
      description: responseData['description'],
      startdate: responseData['startdate'],
      enddate: responseData['enddate'],
      address: responseData['address'],
      postcode: responseData['postcode'],
      city: responseData['city'],
      latitude: responseData['latitude'],
      longitude: responseData['longitude'],
      qrcode: responseData['qrcode'],
      coverpicture: responseData['coverpicture'],
    );
  }
}

