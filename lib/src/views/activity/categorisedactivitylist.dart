import 'package:flutter/material.dart';
import 'package:youth_card/src/objects/activityclass.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:youth_card/src/providers/objectprovider.dart' as objectmodel;
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/util/styles.dart';
import 'package:youth_card/src/util/utils.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/views/activity/activitylistsliver.dart';


import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class CategorisedActivityList extends StatefulWidget {

  final objectmodel.ImageProvider imageProvider;
  final String viewType;

  CategorisedActivityList( this.imageProvider,
      {this.viewType = 'all'});

  @override
  _CategorisedActivityListState createState() =>
      _CategorisedActivityListState();
}

class _CategorisedActivityListState extends State<CategorisedActivityList> {
  Map<String, dynamic>? map;
  List<ActivityClass> data = [];
  User? user;
  LoadingState _loadingState = LoadingState.LOADING;
  bool _isLoading = false;
  int iteration = 1;
  int buildtime = 1;
  int limit = 20;
  int _pageNumber = 0;
  String? errormessage;

  Notify(String text) {
    final snackBar = SnackBar(
      content: Text(text),
    );

    // Find the ScaffoldMessenger in the widget tree
    // and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  _loadNextPage(user) async {
    _isLoading = true;
    int offset = limit * _pageNumber;
    DateTime now = DateTime.now();
    final Map<String, String> params = {
      'loadmethod' :'loadActivityClassesWithActivities',
      'limit': limit.toString(),
      'offset': offset.toString(),
      'api-key': user.token,
      'api_key': user.token,
      'sort': 'name',
    };
    print("categorised activitylist viewtype: " + widget.viewType);

    objectmodel.ActivityClassProvider activityClassProvider = objectmodel
        .ActivityClassProvider();


    print('Loading page $_pageNumber');
    try {
      var activityCategories = await activityClassProvider.loadItems(params);
      setState(() {
        _loadingState = LoadingState.DONE;
        data.addAll(activityCategories);
        print(data.length.toString() + ' activitycategories currently loaded!');
        if(activityCategories.length >= limit) {
          _isLoading = false;
          _pageNumber++;
        }
      });
    } catch (e, stack) {
      _isLoading = false;
      print('loadItems returned error $e\n Stack trace:\n $stack');
      errormessage = e.toString();
      if (_loadingState == LoadingState.LOADING) {
        setState(() => _loadingState = LoadingState.ERROR);
      }
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      User user = Provider
          .of<UserProvider>(context, listen: false)
          .user;
      _loadNextPage(user);
    });
  }

  @protected
  @mustCallSuper
  void dispose() {
    _loadingState = LoadingState.LOADING;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider
        .of<UserProvider>(context, listen: false)
        .user;

    objectmodel.ActivityClassProvider activityClassProvider = objectmodel
        .ActivityClassProvider();
    return new Scaffold(
      backgroundColor: primary,
      appBar: new AppBar(
          title: new Text(AppLocalizations.of(context)!.activities),
          actions: [
      IconButton(
      icon: Icon(Icons.refresh),
        onPressed: () {
          print('Refreshing view');
          setState(() {
            data = [];
            _pageNumber = 0;
            _loadingState = LoadingState.LOADING;
            _isLoading = false;
          });
        }),]
      ),
      body: _getContentSection(user)
      );
  }

  Widget _getContentSection(user) {
    switch (_loadingState) {
      case LoadingState.DONE:
      //data loaded
      print('data loaded, returning customscrollview for '+data.length.toString()+' categories');
        return data.isEmpty ? Container(
            child:Text('Could not find any activities')) : CustomScrollView(
            slivers: <Widget>[
              SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (!_isLoading && index > (data.length * 0.7) && data.length==limit) {
                print('calling loadnextpage, user token is ' + user.token);
                _loadNextPage(user);
              }
             if(data.isNotEmpty) return activityClassView(data[index]);
             else return Container();
            },
            childCount: data.length))]
            );
      case LoadingState.ERROR:
      //data loading returned error state
        return Align(
          alignment: Alignment.center,
          child: ListTile(
            leading: Icon(Icons.error),
            title: Text(
                'Sorry, there was an error loading the activity classes : $errormessage'),
          ),
        );

      case LoadingState.LOADING:
      //data loading in progress
      if(!_isLoading) _loadNextPage(user);
        return Align(
          alignment: Alignment.center,
          child: Center(
            child: ListTile(
              leading: CircularProgressIndicator(),
              title: Text(AppLocalizations.of(context)!.loading,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white)
              ),
            ),
          ),
        );
      default:
        return Container();
    }
  }

  Widget activityClassView(activityClass) {
    objectmodel.ActivityProvider activityProvider = objectmodel
        .ActivityProvider();
    print('creating activity list for class '+activityClass.name);
    return
      Container(
        decoration: BoxDecoration(color: const Color(0xff222128)),
        child: Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(activityClass.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold),
                ),
                Container(
                  height: 400.0,
                  decoration: BoxDecoration(color: primaryDark),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child:
                      ActivityListSliver(  activityProvider, widget.imageProvider, activityClass),
                  ),
                ),
              ]
          ),
        ),
      );
  }


}
