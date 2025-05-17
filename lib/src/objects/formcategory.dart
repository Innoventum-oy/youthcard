import 'package:youth_card/src/objects/form.dart' as icms_form;

enum LoadingStatus {
  idle,
  loading,
  ready,
  error
}
class FormCategory{
  int? id;
  String? name;
  String? description;
  List<icms_form.Form> forms = [];
  FormCategory({this.id, this.name, this.description});
  bool tasksLoaded = false;
  LoadingStatus loadingStatus = LoadingStatus.idle;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }


  factory FormCategory.fromJson(Map<String, dynamic> response) {
    Map<String, dynamic> map = response['data'] ?? response;
    //map.forEach((key, value) { print('$key = $value');});
    return FormCategory(
      id: int.parse(map['id']) ,
      name: map['name'] ,
      description: map['description'] ,
    );
  }



}