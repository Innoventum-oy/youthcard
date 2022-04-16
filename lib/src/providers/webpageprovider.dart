import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/objects/webpage.dart';
import 'package:youth_card/src/util/api_client.dart';

import 'objectprovider.dart';

class WebPageProvider extends ObjectProvider {
  WebPageProvider();
  WebPage _page = new WebPage();
  ApiClient _apiClient = ApiClient();

  WebPage get page => _page;

  void setPage(WebPage page) {
    _page = page;
    notifyListeners();
  }

  void clear() {
    _page = new WebPage();
    notifyListeners();
  }

  Future<void> refresh(User user) async{
    int? id = this.page.id;
    this.clear();
    print('refreshing page '+(id.toString() ));
    if(id!=null){ dynamic result = await this.getDetails(id, user);
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
  Future<dynamic> getDetails(int pageId, user,{reload:false}) {
    return _apiClient.getPageDetails(pageId, user);
  }

  Future<void> loadItem(params) async{
    List<WebPage> pages=[];
    //clear current page
    _page = new WebPage(id: _page.id);
    pages.addAll(await _apiClient.loadPages(params));
    print('webpageprovider loaditem was called for commonname '+params['commonname']+'. pages loaded:'+pages.length.toString());
    if(pages.isNotEmpty) {
      this._page = pages.first;
    }
  }
}