import 'package:flutter/material.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:youth_card/src/views/dashboard.dart';


class Welcome extends StatelessWidget {


  Welcome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("images/splash.png"),
                fit: BoxFit.cover
            ),

        ),
          constraints: BoxConstraints.expand(),
          child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:<Widget>[
                        Image.asset('images/colortextlogo.png'),
                        SizedBox(height: 25.0),
                        ElevatedButton(
                            child: Text(AppLocalizations.of(context)!.btnContinue),
                            onPressed: () {
                              // Navigate to the second screen using a named route.
                              Navigator.pushNamed(context, '/login');
                            }
                        ),
                      ] //children
                   )//row


              )
        );
  }
}
