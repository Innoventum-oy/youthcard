import 'package:flutter/material.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/providers/auth.dart';
import 'package:provider/provider.dart';
import 'package:youth_card/src/views/card.dart';
import 'package:youth_card/src/views/qrscanner.dart';
import 'package:youth_card/src/views/calendar.dart';
import 'package:youth_card/src/views/activitylist.dart';
import 'calendar.dart';
class DashBoard extends StatefulWidget {
  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  @override
  Widget build(BuildContext context) {
    AuthProvider auth = Provider.of<AuthProvider>(context);
    User user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: Text("YouthCard Dashboard"),
        elevation: 0.1,
      ),
      body: Column(
        children: [
          SizedBox(height: 100,),
          Center(child: Text(user.email)),
          SizedBox(height: 50),
          RaisedButton(onPressed: (){
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyCard()),
            );
          }, child: Text("My card"), color: Colors.lightBlueAccent,),
          SizedBox(height: 50),
          RaisedButton(onPressed: (){
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QRScanner()),
            );
          }, child: Text("QR Scanner"), color: Colors.lightBlueAccent,),
          SizedBox(height: 50),
          RaisedButton(onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ActivityCalendar()),
            );
          }, child: Text("Calendar"), color: Colors.lightBlueAccent,),
          SizedBox(height: 50),
          RaisedButton(onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ActivityList()),
            );
          }, child: Text("Discover"), color: Colors.lightBlueAccent,),
          SizedBox(height: 50),
          RaisedButton(onPressed: (){
            auth.logout(user);
          }, child: Text("Logout"), color: Colors.lightBlueAccent,)
        ],
      ),
    );
  }
}