import 'package:youth_card/src/objects/form.dart' as iCMSForm;

enum LoadingStatus {
  Idle,
  Loading,
  Ready,
  Error
}
class FormCategory{
  int? id;
  String? name;
  String? description;
  List<iCMSForm.Form> forms = [];
  FormCategory({this.id, this.name, this.description});
  bool tasksLoaded = false;
  LoadingStatus loadingStatus = LoadingStatus.Idle;

  Map<String, dynamic> toJson() {
    return {
      'id': this.id,
      'name': this.name,
      'description': this.description,
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