import 'package:flutter/material.dart';

class Welcome extends StatelessWidget {


  const Welcome({super.key});

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

              children:<Widget>[
                Expanded(

                    flex: 6,
                    child:
                    Image.asset('images/colortextlogo.png')
                ),
                Flexible(
                    flex:1,
                child:ElevatedButton(
                  onPressed: (){
                    Navigator.pushReplacementNamed(context, '/');

                  },
                  child:Text('Continue')
                )
                ),
                Expanded(
                    flex:1,
                    child: Image.asset('images/erasmusplus.png')
                ),

              ] //children
          )


              )
        );
  }
}
