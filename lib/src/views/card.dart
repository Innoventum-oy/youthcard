import 'package:flutter/material.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:provider/provider.dart';

/*
* User card
*/

class MyCard extends StatefulWidget {
  @override
  _MyCardState createState() => _MyCardState();
}

class _MyCardState extends State<MyCard> {
  @override
  Widget build(BuildContext context) {

    User user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: Text("My Card"),
        elevation: 0.1,
      ),
      body: Column(
        children: [
          SizedBox(height: 50,),
           Center(
               child:user.image!=null ? Image.network(user.image!,height:150) : Image.asset('images/profile.png')
           ),
          Center(child:user.email!=null ? Text(user.email!) : Text('Unknown user')
         ),

          SizedBox(height: 50),
          RaisedButton(onPressed: (){Navigator.pop(context);
          }, child: Text("Return"), color: Colors.lightBlueAccent,),

        ],
      ),
    );
  }
}