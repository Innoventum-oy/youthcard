import 'package:flutter/material.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/providers/auth.dart';
import 'package:provider/provider.dart';
import 'package:youth_card/src/views/card.dart';
import 'package:youth_card/src/views/qrscanner.dart';
import 'package:youth_card/src/views/calendar.dart';
import 'package:youth_card/src/providers/objectprovider.dart' as objectmodel;
import 'package:youth_card/src/views/activitylist.dart';

class DashBoard extends StatefulWidget {
  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  @override
  Widget build(BuildContext context) {
    AuthProvider auth = Provider.of<AuthProvider>(context);
    User user = Provider.of<UserProvider>(context).user;

    objectmodel.ActivityProvider provider = objectmodel.ActivityProvider();
    objectmodel.ImageProvider imageprovider = objectmodel.ImageProvider();
    return Scaffold(
      appBar: AppBar(
        title: Text("YouthCard Dashboard"),
        elevation: 0.1,
        actions: [
          IconButton(
            icon:user.image!=null ? Image.network(user.image!,height:50) : Image.asset('images/profile.png'),
            onPressed: () {
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyCard()),
              );
            }
            )
          ],
      ),
        body:
          GridView.count(
          // Create a grid with 2 columns. If you change the scrollDirection to
          // horizontal, this produces 2 rows.
          crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            padding:EdgeInsets.only(
              top:10
            ),
          children: [
            MaterialButton(
             //padding: EdgeInsets.all(8.0),
              textColor: Colors.white,
              splashColor: Colors.greenAccent,
             // elevation: 8.0,
              child: Stack(
                children:[
                  Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: (user.image!=null ?
                      NetworkImage(user.image!) :
                      AssetImage('images/profile.png') as ImageProvider),
                      fit: BoxFit.cover,
                  ),
                ),

              /*  child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("SIGN OUT"),
                ),

               */
              ),
                Center(
                child:Text('My Card'),
                ),
              ]),
              // ),
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyCard()),
                );
              },
            ),

          ElevatedButton(onPressed: (){
            Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => QRScanner()),
          );
          }, child: Text("QR Scanner"),

        ),

          ElevatedButton(onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ActivityCalendar(provider,imageprovider)),
            );
          }, child: Text("Calendar"),
          ),

          ElevatedButton(onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ActivityList(provider,imageprovider)),
            );
          }, child: Text("Discover"), ),

          ElevatedButton(onPressed: (){
            auth.logout(user);
          }, child: Text("Logout"), )
        ],
      ),

    );
  }
}