import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/objects/webpage.dart';

import 'objectprovider.dart';

class WebPageProvider extends ObjectProvider {
  WebPageProvider();
  WebPage _page = WebPage();
  final ApiClient _apiClient = ApiClient();

  WebPage get page => _page;

  void setPage(WebPage page) {
    _page = page;
    notifyListeners();
  }

  void clear() {
    _page = WebPage();
    notifyListeners();
  }

  Future<void> refresh(User user) async{
    int? id = page.id;
    clear();

    if(id!=null){ dynamic result = await getDetails(id, user);
    if(result!=null) {
      _page = WebPage.fromJson(result);
      notifyListeners();
    }
    }

  }

  @override
  Future<List<WebPage>> loadItems(params) async {

    return _apiClient.loadPages(params);
  }

// returns json-decoded response
  @override
  Future<dynamic> getDetails(int pageId, user,{reload =false}) {
    return _apiClient.getPageDetails(pageId, user);
  }

  Future<void> loadItem(params) async{
    List<WebPage> pages=[];
    //clear current page
    _page = WebPage(id: _page.id);
    pages.addAll(await _apiClient.loadPages(params));
    if(pages.isNotEmpty) {
      _page = pages.first;
    }
  }
}