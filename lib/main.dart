import 'package:flutter/material.dart';
import 'package:youth_card/l10n/app_localizations.dart'; // important
import 'package:youth_card/src/providers/activity_list_provider.dart';
import 'package:youth_card/src/providers/web_page_provider.dart';
import 'package:youth_card/src/views/card.dart';
import 'package:youth_card/src/views/dashboard.dart';
import 'package:youth_card/src/views/loginform.dart';
import 'package:youth_card/src/views/register.dart';
import 'package:youth_card/src/views/passwordform.dart';
import 'package:youth_card/src/views/settings/contactmethods.dart';
import 'package:youth_card/src/views/userform.dart';
import 'package:youth_card/src/views/validatecontact.dart';
import 'package:youth_card/src/views/welcome.dart';
import 'package:youth_card/src/providers/auth.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/util/shared_preference.dart';
import 'package:provider/provider.dart';
import 'package:feedback/feedback.dart';
import 'src/objects/user.dart';

void main() {
  runApp(
      BetterFeedback(
          child:YouthCard(),
      )
  );
}
class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();
}

ThemeData _appTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final colors = ColorScheme.fromSeed(
    seedColor: const Color(0xFF0A6059),
    brightness: brightness,
    primary: dark ? const Color(0xFF8DD7C9) : const Color(0xFF0A6059),
    secondary: dark ? const Color(0xFFFFC6A6) : const Color(0xFF9B532E),
    surface: dark ? const Color(0xFF111A1B) : const Color(0xFFFAFBF7),
  );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colors,
    scaffoldBackgroundColor: colors.surface,
    cardTheme: CardThemeData(
      color: dark ? const Color(0xFF1B292A) : Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colors.surface,
      foregroundColor: colors.onSurface,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.surfaceContainerLow,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}

class YouthCard extends StatefulWidget {
  const YouthCard({super.key});

  @override
  State<YouthCard> createState() => _YouthCardState();
}

class _YouthCardState extends State<YouthCard> {
  late final Future<User> _storedUser;

  @override
  void initState() {
    super.initState();
    _storedUser = UserPreferences().getUser();
  }

  // This widget is the root of Youth Card application.
  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => WebPageProvider()),
        ChangeNotifierProvider(create: (_) => ActivityListProvider()),
      ],
      child: MaterialApp(
          title: 'Youth Card',
          navigatorKey: NavigationService.navigatorKey,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,

          theme: _appTheme(Brightness.light),
          darkTheme: _appTheme(Brightness.dark),
          themeMode: ThemeMode.system,
          home: FutureBuilder(
              future: _storedUser,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {

                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Welcome(); //return CircularProgressIndicator();

                  default:

                    // User userdata =  UserPreferences().getUser(); //User();
                    if(snapshot.hasData)
                    {
                      User userdata = snapshot.data as User;
                      if(snapshot.data == null) {
                      } else {
                      }
                      if (userdata.token != null)
                      {
                        Provider.of<UserProvider>(context, listen: false).setUserSilent(userdata);
                        return DashBoard();
                      }
                    }
                    else {
                    }

                    if (snapshot.hasError) {
                      return Login(user:User()); //Text('Error: ${snapshot.error}');
                    }
                    else
                      {
                       return Login(user:User());
                      }
                }
              }),
          routes: {
            '/dashboard': (context) => DashBoard(),
            '/login': (context) => Login(),
            '/register': (context) => Register(),
            '/reset-password': (context) => ResetPassword(),
            '/validatecontact' : (context) => ValidateContact(),
            '/contactmethods' : (context) => ContactMethodsView(),
            '/userform' : (context) => UserForm(),
            '/welcome' : (context) => Welcome(),
            '/card' : (context) => MyCard(),
          }),
    );
  }
}

/*
this homepage implementation is not used:
class HomePage extends StatefulWidget {
  HomePage({Key? key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String? title;

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
        title: Text(widget.title.toString()),
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
*/
