import 'package:flutter/material.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
        title: Text(AppLocalizations.of(context)!.myCard),
        elevation: 0.1,
      ),
      body: Column(
        children: [


          SizedBox(height: 50),
          Center(child:_loggedInView(context, user)),

          SizedBox(height: 50),
          Center(
              child:user.qrcode!=null && user.qrcode!.isNotEmpty ? Image.network(user.qrcode!,height:200) : Container()
          ),
         SizedBox(height: 50),
         ElevatedButton(onPressed: (){Navigator.pop(context);
          }, child: Text(AppLocalizations.of(context)!.btnReturn)
    ),
        ],
      ),
    );

  }
  Widget _loggedInView(BuildContext context, user) {
    List<String> nameparts=[];
    nameparts.add(user.firstname ?? 'John');
    nameparts.add(user.lastname ?? 'Doe');

    String username = nameparts.join(' ');
    return Column(
      children: <Widget>[
        _drawAvatar(user.image!=null && user.image!.isNotEmpty ? NetworkImage(user.image) : Image.asset('images/profile.png').image),
        _drawLabel(context, username),
        Text(user.email),

      ],
    );
  }
  Padding _drawLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        label,
        style: Theme.of(context).textTheme.display1,
      ),
    );
  }

  Padding _drawAvatar(ImageProvider imageProvider) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: CircleAvatar(
        backgroundImage: imageProvider,
        backgroundColor: Colors.white10,
        radius: 48.0,
      ),
    );
  }

}