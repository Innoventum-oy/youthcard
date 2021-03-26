import 'package:flutter/material.dart';
import 'package:youth_card/src/objects/activity.dart';
import 'package:http/http.dart' as http;
import 'package:youth_card/src/providers/objectprovider.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/util/app_url.dart';
import 'package:youth_card/src/views/activitylist_item.dart';
import 'dart:async';
import 'dart:convert';
import 'package:provider/provider.dart';


class ActivityList extends StatefulWidget {
  @override
  _ActivityListState createState() => _ActivityListState();
}

class _ActivityListState extends State<ActivityList>  {

  Map<String,dynamic> map;
  List<Activity> data =[];
  User user;
  bool _dataloading = false;
  int iteration =1;
  int buildtime = 1;
  Notify(String text) {
    final snackBar = SnackBar(
      content: Text(text),
    );

    // Find the ScaffoldMessenger in the widget tree
    // and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> getData(user) async {
    // print(user);
    print('getdata called');
   // try {
      _dataloading = true;
      print('attempt $iteration loading data from ' + AppUrl.baseURL +
          '/api/activity/' + ' using token ' + user.token);
      iteration++;
      Map<String, String> params = {
        'activitystatus': 'active',
        'activitytype': 'activity',
        'limit' : '50',
      };
      var url = Uri.https(AppUrl.baseURL, '/api/activity/', params);
      var response = await http.get(url, headers: { 'api_key': user.token});

      setState(() {
        print('getdata is setting state');
        map = json.decode(response.body);
        if (map != null) {
          print(map['data'].length.toString() + ' items loaded!');
          for (var a in map['data']) {

            Activity item = Activity.fromJson(a);
            data.add(item);
          }
        }
        else print('null response received!');
        _dataloading = false;
      });
  /*  } catch (e) {
      print('error occurred: $e');
    }*/
  }

  @override
  void initState(){
    print('initing state');
    _dataloading = false;
  }

  @override
  Widget build(BuildContext context){

    print('build $buildtime of activitylist view');
    buildtime++;

    User user = Provider.of<UserProvider>(context).user;
    if(data.length==0 && _dataloading==false) {
      print('data is null, calling getdata');
      this.getData(user);
    }


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
}