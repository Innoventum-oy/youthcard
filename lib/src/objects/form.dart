
import 'package:youth_card/src/objects/formelement.dart';

enum LoadingStatus {
  Idle,
  Loading,
  Ready,
  Error
}
class Form{
  int? id;
  String? title;
  String? description;
  bool isExpanded;
  List<FormElement> elements = [];
  LoadingStatus loadingStatus = LoadingStatus.Idle;

  Form({this.id, this.title, this.description,this.isExpanded =false}){
    elements = [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title ??'',
      'description': description ??'',
    };
  }

  factory Form.fromJson(Map<String, dynamic> response) {
    Map<String, dynamic> map = response['data'] ?? response;

    return Form(
      id: int.parse(map['id']) ,
      title: map['title'] ,
      description: map['description'] ,
    );
  }
}