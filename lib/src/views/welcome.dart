import 'package:flutter/material.dart';

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

                      ] //children
                   )//row


              )
        );
  }
}
