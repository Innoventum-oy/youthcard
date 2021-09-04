import 'package:youth_card/src/objects/webpage.dart';
import 'package:youth_card/src/util/api_client.dart';

import 'objectprovider.dart';

class WebPageProvider extends ObjectProvider {
  WebPageProvider();

  ApiClient _apiClient = ApiClient();

  @override
  Future<List<WebPage>> loadItems(params) async {

    return _apiClient.loadPages(params);
  }

// returns json-decoded response
  @override
  Future<dynamic> getDetails(int pageId, user,{reload:false}) {
    return _apiClient.getPageDetails(pageId, user);
  }
}