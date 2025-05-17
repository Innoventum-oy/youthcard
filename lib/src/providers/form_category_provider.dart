import '../objects/formcategory.dart';
import 'objectprovider.dart';

class FormCategoryProvider extends ObjectProvider {
  FormCategoryProvider();

  final ApiClient _apiClient = ApiClient();

  @override
  Future<List<FormCategory>> loadItems(params) async {

    return _apiClient.loadFormCategories(params);

  }

  /// returns json-decoded response
  @override
  Future<dynamic> getDetails(int id,user) {
    return _apiClient.getFormCategoryDetails(id,user);
  }
}