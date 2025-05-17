import 'objectprovider.dart';
import 'package:youth_card/src/objects/form.dart' as icms_form;

class FormProvider extends ObjectProvider {
  FormProvider();
  final ApiClient _apiClient = ApiClient();

  @override
  Future<List<icms_form.Form>> loadItems(params) async {

    return _apiClient.loadForms(params);

  }
// returns json-decoded response
  @override
  Future<dynamic> getDetails(int formId,user) {
    return _apiClient.getFormDetails(formId,user);
  }



}