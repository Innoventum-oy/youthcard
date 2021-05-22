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
    return OrientationBuilder(
      builder: (context,orientation)
    {
      print(orientation);
      return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.myCard),
            elevation: 0.1,
          ),
          body: orientation == Orientation.portrait
              ? _portraitLayout(user)
              : _landscapeLayout(user)
      );
    });

  }
  Widget _portraitLayout(user)
  {
    return Column(
      children: [

        SizedBox(height: 20),
        Center(
            child:user.qrcode!=null && user.qrcode!.isNotEmpty ? Image.network(user.qrcode!,height:200) : Container()
        ),

        SizedBox(height: 20),
        Center(child:_loggedInView(context, user)),
        SizedBox(height: 20),
        ElevatedButton(onPressed: (){Navigator.pop(context);
        }, child: Text(AppLocalizations.of(context)!.btnReturn)
        ),
      ],
    );
  }
  Widget _landscapeLayout(user)
  {
    return Padding(
        padding:EdgeInsets.all(30),
    child:Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        user.qrcode!=null && user.qrcode!.isNotEmpty ?
          Image.network(user.qrcode!,height:200) :
          Container(),
        _loggedInView(context, user),

      ],
    )
    );
  }
  Widget _loggedInView(BuildContext context, user) {
    List<String> nameparts=[];
    nameparts.add(user.firstname ?? 'John');
    nameparts.add(user.lastname ?? 'Doe');

    String username = nameparts.join(' ');
    return Padding(
        padding:EdgeInsets.only(left:20,right:20),
    child:Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _drawAvatar(user.image!=null && user.image!.isNotEmpty ? NetworkImage(user.image) : Image.asset('images/profile.png').image),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
            _drawLabel(context, username),
            Text(user.email),
          ]
        )

      ],
    ),
    );
  }
  Padding _drawLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        label,
        style: Theme.of(context).textTheme.headline5,
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