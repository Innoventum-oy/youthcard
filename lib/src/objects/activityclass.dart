import 'package:intl/intl.dart';

class ActivityClass {
  int? id;
  String? name;
  String? description;
  String? coverpicture;
  String? coverpictureurl;
  int accesslevel;

  ActivityClass({this.id, this.name, this.description,this.coverpicture,this.coverpictureurl,this.accesslevel=0});



  factory ActivityClass.fromJson(Map<String, dynamic> response) {

    Map<String, dynamic> responseData =  response['data'];
    responseData.forEach((key, value) { print('$key = $value');});
    Map<String, dynamic>? cover = responseData['coverpicture'] ?? null;
    return ActivityClass(
        id: responseData['objectid'] !=null ? int.parse(responseData['objectid']) : null,
        name: responseData['name'],
        description: responseData['description'],
        coverpicture: cover == null ? 'default' : cover['objectid'],
        coverpictureurl: responseData['coverpictureurl'],
        accesslevel: responseData['accesslevel'] is int ? responseData['accesslevel'] : int.parse(responseData['accesslevel'])
    );
  }

  Map toJson() => {
    'id' : id,
    'name': name,
    'description' : description,
    'coverpicture':coverpicture,
    'coverpictureurl' : coverpictureurl,
  };
}

