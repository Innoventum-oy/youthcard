import 'package:intl/intl.dart';
class ImageObject{
  int? id;
  int? category;
  String? author;
  DateTime? date;

  String? ext;
  String? filename;
  String? filepath;
  String? imageName;
  String? keywords;
  int state = 1;
  String? text;
  String? urlpath;

  ImageObject({this.id,this.category,this.text,this.author,this.date,this.ext,this.filename,this.filepath,this.imageName,this.state=1,this.urlpath});

  factory ImageObject.fromJson(Map<String, dynamic> response) {
    Map<String, dynamic> responseData = response['data'];
    return ImageObject(
      id: int.parse(responseData['id']),
      category: int.parse(responseData['category']),
      imageName: responseData['imagename'],
      text: responseData['text'],
      author: responseData['author'],
      date: DateFormat('dd.MM.yyyy HH:mm:ss').parse(responseData['date']),

      filename: responseData['filename'],
      filepath: responseData['filepath'],
      ext: responseData['ext'],
      urlpath: responseData['urlpath'],
    );
  }

}