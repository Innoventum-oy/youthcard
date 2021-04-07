import 'package:flutter/material.dart';
import 'package:youth_card/src/views/dashboard.dart';
import 'package:youth_card/src/views/loginform.dart';
import 'package:youth_card/src/views/register.dart';
import 'package:youth_card/src/views/welcome.dart';
import 'package:youth_card/src/providers/auth.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/util/shared_preference.dart';
import 'package:youth_card/src/util/styles.dart';
import 'package:provider/provider.dart';

import 'src/objects/user.dart';




void main() {
  runApp(YouthCard());
}

class YouthCard extends StatelessWidget {
  // This widget is the root of Youth Card application.
  @override
  Widget build(BuildContext context) {
    Future<User> getUserData() => UserPreferences().getUser();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
    child: MaterialApp(
      title: 'Youth Card',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.deepOrange,
        accentColor: Colors.teal,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder(
        future: getUserData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return CircularProgressIndicator();
            default:
              if (snapshot.hasError)
                return Text('Error: ${snapshot.error}');
              else if (snapshot.data.token == null)
                return Login();
              else
                UserPreferences().removeUser();
            return Welcome(user: snapshot.data);
          }
      }),
        routes: {
      '/dashboard': (context) => DashBoard(),
      '/login': (context) => Login(),
      '/register': (context) => Register(),
      }),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Container(
        decoration: BoxDecoration(
          image:DecorationImage(
            image: AssetImage("images/splash.png"),
            fit:BoxFit.cover,
          )
        ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:[
            Image.asset('images/logowhite.png',
          fit:BoxFit.cover,
          ),
          ElevatedButton(child: Text('My Card'),
          onPressed: null,
          ),
          ElevatedButton(child: Text('Scan QR'),
            onPressed: null,
          ),
          ElevatedButton(child: Text('Activities'),
            onPressed: null,
          ),
          ]
        ),
      ),


      )
    );
  }
}


