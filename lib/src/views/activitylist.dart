import 'package:flutter/material.dart';
import 'package:youth_card/src/objects/activity.dart';
import 'package:http/http.dart' as http;
import 'package:youth_card/src/providers/activityloader.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/util/app_url.dart';
import 'dart:async';
import 'dart:convert';
import 'package:provider/provider.dart';


class ActivityList extends StatefulWidget {
  @override
  _ActivityListState createState() => _ActivityListState();
}

class _ActivityListState extends State<ActivityList>  {

  Map<String,dynamic> map;
  List data;
  User user;

  Future<String> getData(user) async {
    print(user);
    print('loading data from '+AppUrl.baseURL + '/activity/'+' using token '+user.token);
    var response = await http.get(AppUrl.baseURL + '/activity/',headers:{ 'api_key':user.token});

    this.setState(() {
   //   print('received data '+response.body);
    map = json.decode(response.body);
    });
    data = map['data'];
    print(data[0]["text"]);

    return "Success";
  }

  @override
  void initState(){


  }

  @override
  Widget build(BuildContext context){

    User user = Provider.of<UserProvider>(context).user;
    this.getData(user);
    return new Scaffold(
      appBar: new AppBar(title: new Text("Listviews"), backgroundColor: Colors.blue),
      body: new ListView.builder(
        itemCount: data == null ? 0 : data.length,
        itemBuilder: (BuildContext context, int index){
          return new Card(
            child: new Text(data[index]["text"]),
          );
        },
      ),
    );
  }
}