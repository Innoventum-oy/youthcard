import '../objects/formelement.dart';
import 'objectprovider.dart';

class FormElementProvider extends ObjectProvider {
  FormElementProvider();

  final ApiClient _apiClient = ApiClient();

  @override
  Future<List<FormElement>> loadItems(params) async {

    return _apiClient.loadFormElements(params);

  }
  Future<List<FormElement>> getElements(params) async {

    return _apiClient.getElements(params);

  }
// returns json-decoded response
  @override
  Future<dynamic> getDetails(int id,user) {
    return _apiClient.getFormElementDetails(id,user);
  }

}