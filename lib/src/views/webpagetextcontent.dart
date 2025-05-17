import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/providers/web_page_provider.dart';
import 'package:provider/provider.dart';
import 'package:youth_card/l10n/app_localizations.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/util/utils.dart';
import'package:youth_card/src/objects/webpage.dart';
import 'package:flutter_html/flutter_html.dart';

/*
* Privacy policy - display page. Fetches the page contents from server based on commonname + language parameters.
* Expects to receive array of text blocks to display
*/

class ContentPageView extends StatefulWidget {
  final String commonname;
  final WebPage? providedPage;
  final WebPageProvider pageProvider = WebPageProvider();

  ContentPageView(this.commonname,{super.key, this.providedPage});
  @override
  ContentPageViewState createState() => ContentPageViewState();
}

class ContentPageViewState extends State<ContentPageView> {

  LoadingState _pageLoadingState = LoadingState.loading;
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
      await widget.pageProvider.loadItem(params);
      setState(() {
        pages.add(widget.pageProvider.page);
        _pageLoadingState = LoadingState.done;

        //pages.addAll(result);
        // print(result.length.toString() + ' pages currently loaded!');
        //_isLoading = false;
      });
    } catch (e) {
      // _isLoading = false;
      errormessage = e.toString();
      if (_pageLoadingState == LoadingState.loading) {
        setState(() => _pageLoadingState = LoadingState.error);
      }
    }
  }
  _setWebPage(){
    pages.add(widget.providedPage!);
    setState(() =>
    _pageLoadingState = LoadingState.done);
  }
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      User user = Provider.of<UserProvider>(context, listen: false).user;

      if(widget.providedPage!=null) {
        _setWebPage();
      }
      else {
        _loadWebPage(widget.commonname, user);

      }
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
      case LoadingState.done:
      //data loaded
        if(pages.isEmpty) {
          return ListTile(
              leading: Icon(Icons.error),
              title: Text('${AppLocalizations.of(context)!.contentNotFound} (${widget.commonname} [${Localizations.localeOf(context)}])'));
        }
        return ListView.builder(
            itemCount: pages.length,
            itemBuilder: (BuildContext context, int index) {
              return _pageContentSection(pages[index]);
            });

      case LoadingState.error:
      //data loading returned error state
        return Container(
          alignment: Alignment.center,
          child: ListTile(
            leading: Icon(Icons.error),
            title: Text(
                'Sorry, there was an error loading the data: $errormessage'),
          ),
        );

      case LoadingState.loading:
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
    if(kDebugMode){
      log('Displaying page ${page.id}');
    }
    if(page.textcontents!=null && page.textcontents.length>0) {

      for (var i in page.textcontents) {
        textContents.add(Html(data: i.toString()));

      }
    }
    else {

      textContents.add(Padding(padding: EdgeInsets.all(20),
          child: Text(AppLocalizations.of(context)!.pageIsEmpty)));
    }
    return Column(
        children:textContents
    );
  }
}
