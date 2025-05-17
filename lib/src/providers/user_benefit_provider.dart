import '../objects/userbenefit.dart';
import 'objectprovider.dart';

class UserBenefitProvider extends ObjectProvider {
  UserBenefitProvider();

  final ApiClient _apiClient = ApiClient();

  @override
  Future<List<UserBenefit>> loadItems(params) async {
    return _apiClient.loadUserBenefits(params);
  }

// returns json-decoded response
  @override
  Future<dynamic> getDetails(int benefitId, user,{reload =false}) {
    return _apiClient.getUserBenefitDetails(benefitId, user);
  }
}
