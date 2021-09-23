import 'package:flutter/material.dart';
import 'package:youth_card/src/objects/activity.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:youth_card/src/providers/objectprovider.dart' as objectmodel;
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/util/utils.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/views/activity/activitylist_item.dart';

import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ActivityList extends StatefulWidget {
  final String viewTitle = 'activitylist';
  final objectmodel.ActivityListProvider activityProvider;
  final objectmodel.ImageProvider imageProvider;
  final String viewType;
  ActivityList(this.activityProvider,this.imageProvider,{this.viewType='all'});
  @override
  _ActivityListState createState() => _ActivityListState();
}

class _ActivityListState extends State<ActivityList>  {

  Map<String,dynamic>? map;
  List<Activity> data =[];
  User? user;
  LoadingState _loadingState = LoadingState.LOADING;
  bool _isLoading = false;
  int iteration =1;
  int buildtime = 1;
  int limit = 20;
  int _pageNumber = 0;
  String? errormessage;

  notify(String text) {
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
      'activitystatus': 'active',
      'limit' : limit.toString(),
      'offset' : offset.toString(),
      'api_key':user.token,

    };
    print("activitylist type:"+widget.viewType);

    switch(widget.viewType)
    {
      case 'locations':
        params['activitytype'] = 'location';
        params['sort'] = 'name';
        break;
      case 'own':
        params['activitytype'] = 'activity';
        params['accesslevel']='modify';
        params['startfrom'] = DateFormat('yyyy-MM-dd').format(now);
        //   params['limit']='NULL';
      break;
      default:
        params['activitytype'] = 'activity';
        params['startfrom'] = DateFormat('yyyy-MM-dd').format(now);
        params['sort'] ='nexteventdate';

    }
    print('Loading activitylist page $_pageNumber');
    try {

      var nextActivities =
      await widget.activityProvider.loadItems(params);
      setState(() {
        _loadingState = LoadingState.DONE;
        if(nextActivities.isNotEmpty) {
          data.addAll(nextActivities);
          print(data.length.toString() + ' activities currently loaded!');
          _isLoading = false;
          _pageNumber++;
        }
        else
          {
            print('no more activities were found');
          }
      });
    } catch (e,stack) {
      _isLoading = false;
      print('loadItems returned error $e\n Stack trace:\n $stack');
      errormessage = e.toString();
      if (_loadingState == LoadingState.LOADING) {
        setState(() => _loadingState = LoadingState.ERROR);
      }
    }
  }

  @override
  void initState(){
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {

      User user = Provider.of<UserProvider>(context,listen: false).user;

      _loadNextPage(user);
    });
  super.initState();

  }

  @override
  Widget build(BuildContext context){

  print('viewtype: '+widget.viewType);

  User user = Provider.of<UserProvider>(context,listen: false).user;
  bool isTester = false;
  if(user.data!=null) {
    print(user.data.toString());
    if (user.data!['istester'] != null) {
      if (user.data!['istester'] == 'true') isTester = true;
    }
  }

  return new Scaffold(
      appBar: new AppBar(
          title: new Text(
            widget.viewType=='locations' ? AppLocalizations.of(context)!.locations : AppLocalizations.of(context)!.activities),
          actions: [
          if(isTester) IconButton(
      icon: Icon(Icons.bug_report),
    onPressed:(){feedbackAction(context,user); }
    ),
    ]
    ),
      body: _getContentSection(user)
    );
  }

  Widget _getContentSection(user) {
   // User user = Provider.of<UserProvider>(context).user;

    switch (_loadingState) {
      case LoadingState.DONE:

        //data loaded
        return ListView.builder(
            itemCount: data.length,
            itemBuilder: (BuildContext context, int index) {
              if (!_isLoading && index > (data.length * 0.7)) {
              print('calling loadnextpage, user token is '+user.token);
                _loadNextPage(user);
              }

              return ActivityListItem(data[index]);
            });
      case LoadingState.ERROR:
        //data loading returned error state
        return Align(alignment:Alignment.center,
            child:ListTile(
              leading: Icon(Icons.error),
              title: Text('Sorry, there was an error loading the data: $errormessage'),
            ),
        );

      case LoadingState.LOADING:
        //data loading in progress
        return Align(alignment:Alignment.center,
          child:Center(
            child:ListTile(
              leading:CircularProgressIndicator(),
              title: Text(AppLocalizations.of(context)!.loading,textAlign: TextAlign.center),
          ),
          ),
        );
      default:
        return Container();
    }
  }

}