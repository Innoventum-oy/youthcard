import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
class ImageObject{
  int id;
  int category;
  String author;
  DateTime date;

  String ext;
  String filename;
  String filepath;
  String imagename;
  String keywords;
  int state;
  String text;
  String urlpath;

  ImageObject({this.id,this.category,this.text,this.author,this.date,this.ext,this.filename,this.filepath,this.imagename,this.state,this.urlpath});

  factory ImageObject.fromJson(Map<String, dynamic> response) {
    Map<String, dynamic> responseData = response['data'];
    return ImageObject(
      id: int.parse(responseData['id']),
      category: int.parse(responseData['category']),
      imagename: responseData['imagename'],
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