import 'package:flutter/material.dart';
import 'package:youth_card/src/objects/activity.dart';
import 'package:http/http.dart' as http;
import 'package:youth_card/src/providers/objectprovider.dart' as objectmodel;
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/util/utils.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/util/app_url.dart';
import 'package:youth_card/src/views/activitylist_item.dart';
import 'dart:async';
import 'dart:convert';
import 'package:provider/provider.dart';


class ActivityList extends StatefulWidget {
  final objectmodel.ActivityProvider provider;
  final objectmodel.ImageProvider imageprovider;

  ActivityList(this.provider,this.imageprovider);
  @override
  _ActivityListState createState() => _ActivityListState();
}

class _ActivityListState extends State<ActivityList>  {

  Map<String,dynamic> map;
  List<Activity> data =[];
  User user;
  LoadingState _loadingState = LoadingState.LOADING;
  bool _dataloading = false;
  bool _isLoading = false;
  int iteration =1;
  int buildtime = 1;
  int limit = 50;
  int _pageNumber = 0;
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
    Map<String, String> params = {
      'activitystatus': 'active',
      'activitytype': 'activity',
      'limit' : '50',
      'offset' : offset.toString(),
      'api-key':user.token,
      'api_key':user.token,
    };
    Notify('Loading page $_pageNumber');
    try {

      var nextActivities =
      await widget.provider.loadItems(params);
      setState(() {
        _loadingState = LoadingState.DONE;
        print(nextActivities.length.toString()+' activities loaded!');
        data.addAll(nextActivities);
        _isLoading = false;
        _pageNumber++;
      });
    } catch (e) {
      _isLoading = false;
      print('loadItems returned error $e');
      if (_loadingState == LoadingState.LOADING) {
        setState(() => _loadingState = LoadingState.ERROR);
      }
    }
  }

  @override
  void initState(){

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {

      User user = Provider.of<UserProvider>(context,listen: false).user;

      _loadNextPage(user);
    });


  }

  @override
  Widget build(BuildContext context){

    print('debug: build $buildtime of activitylist view');
    buildtime++;



    return new Scaffold(
      appBar: new AppBar(title: new Text("Activities"), backgroundColor: Colors.blue),
      body: (_dataloading || data.length==0) ?   Row(children:[
        CircularProgressIndicator(),
        Text('Please wait, loading data'),
      ]
      ) : new ListView.builder(
        itemCount:  data.length,
        itemBuilder: (BuildContext context, int index){
          return ActivityListItem(data[index]);
        },
      ),
    );
  }

  Widget _getContentSection() {
    switch (_loadingState) {
      case LoadingState.DONE:
        //data loaded
        return ListView.builder(
            itemCount: data.length,
            itemBuilder: (BuildContext context, int index) {
              if (!_isLoading && index > (data.length * 0.7)) {
                _loadNextPage(user);
              }

              return ActivityListItem(data[index]);
            });
      case LoadingState.ERROR:
        //data loading returned error state
        return Text('Sorry, there was an error loading the data');

      case LoadingState.LOADING:
        //data loading in progress
        return CircularProgressIndicator();
      default:
        return Container();
    }
  }

}