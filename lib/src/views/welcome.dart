import 'package:flutter/material.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:youth_card/src/views/dashboard.dart';


class Welcome extends StatelessWidget {
  final User user;

  Welcome({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    Provider.of<UserProvider>(context).setUser(user);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("images/splash.png"),
                fit: BoxFit.cover
            ),

        ),
          constraints: BoxConstraints.expand(),
          child:
                Expanded(
                  child:
                   Center(
                   child:
                    Row(
                      children:<Widget>[
                        Text("YOUTH CARD"),
                        ElevatedButton(
                            child: Text('Continue'),
                            onPressed: () {
                              // Navigate to the second screen using a named route.
                              Navigator.pushNamed(context, '/dashboard');
                            }
                        ),
                      ] //children
                   )//row
                )//center
                )//expanded

              )
        );
  }
}
