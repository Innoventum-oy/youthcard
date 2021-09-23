import 'package:flutter/material.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/providers/webpageprovider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/util/utils.dart';
import'package:youth_card/src/objects/webpage.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:youth_card/src/util/utils.dart';
/*
* Privacy policy - display page. Fetches the page contents from server based on commonname + language parameters.
* Expects to receive array of text blocks to display
*/

class ContentPageView extends StatefulWidget {
  final String commonname;
  final WebPage? providedPage;
  final WebPageProvider pageProvider = WebPageProvider();

  ContentPageView(this.commonname,{this.providedPage});
  @override
  _ContentPageViewState createState() => _ContentPageViewState();
}

class _ContentPageViewState extends State<ContentPageView> {

  LoadingState _pageLoadingState = LoadingState.LOADING;
  String? errormessage;
  List<WebPage> pages = [];

  _loadWebPage(String commonname,user) async {

    final Map<String, String> params = {

      'language' : Localizations.localeOf(context).toString(),
      'commonname': commonname,
      'fields' :'id,commonname,pagetitle,textcontents',
       if(user.token!=null) 'api_key': user.token,

    };

    try {
      pages = await loadPages(context,commonname,user);
      setState(() {
        _pageLoadingState = LoadingState.DONE;

        //pages.addAll(result);
       // print(result.length.toString() + ' pages currently loaded!');
        //_isLoading = false;
      });
    } catch (e, stack) {
     // _isLoading = false;
      print('loadItems returned error $e\n Stack trace:\n $stack');
      errormessage = e.toString();
      if (_pageLoadingState == LoadingState.LOADING) {
        setState(() => _pageLoadingState = LoadingState.ERROR);
      }
    }
  }
  _setWebPage(){
    pages.add(widget.providedPage!);
    setState(() =>
    _pageLoadingState = LoadingState.DONE);
  }
  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      User user = Provider.of<UserProvider>(context, listen: false).user;

      if(widget.providedPage!=null) _setWebPage();
      else _loadWebPage(widget.commonname,user);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).user;


      return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.pageContent),
            elevation: 0.1,
          ),
          body: _getPageSection(user)
    );
  }


  Widget _getPageSection(user) {
    switch (_pageLoadingState) {
      case LoadingState.DONE:
      //data loaded
        if(pages.isEmpty) return Container(child:Text('No content found'));
        return ListView.builder(
                itemCount: pages.length,
                itemBuilder: (BuildContext context, int index) {
                  return _pageContentSection(pages[index]);
                });

      case LoadingState.ERROR:
      //data loading returned error state
        return Container(
          alignment: Alignment.center,
          child: ListTile(
            leading: Icon(Icons.error),
            title: Text(
                'Sorry, there was an error loading the data: $errormessage'),
          ),
        );

      case LoadingState.LOADING:
      //data loading in progress
        return Container(
          alignment: Alignment.center,
          child: Center(
            child: ListTile(
              leading: CircularProgressIndicator(),
              title: Text(AppLocalizations.of(context)!.loading,
                  textAlign: TextAlign.center),
            ),
          ),
        );
      default:
        return Container();
    }
  }

  Widget _pageContentSection(page) {
    List<Widget> textContents = [];
    for(var i in page.textcontents)
      textContents.add(Html(data:i.toString()));
    return Container(
        child:
            Column(
            children:textContents
            )

        );
  }
}
