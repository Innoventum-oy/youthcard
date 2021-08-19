import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/providers/auth.dart';
import 'package:provider/provider.dart';
import 'package:youth_card/src/views/card.dart';
import 'package:youth_card/src/views/qrscanner.dart';
import 'package:youth_card/src/views/calendar.dart';
import 'package:youth_card/src/objects/activity.dart';
import 'package:youth_card/src/providers/objectprovider.dart' as objectmodel;
import 'package:youth_card/src/views/activity/activitylist.dart';
import 'package:youth_card/src/views/activity/categorisedactivitylist.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:youth_card/src/views/settings.dart';
import 'package:youth_card/src/util/utils.dart';
import 'package:intl/intl.dart';
import 'package:youth_card/src/views/loginform.dart';
import 'package:youth_card/src/util/shared_preference.dart';

class DashBoard extends StatefulWidget {
  final objectmodel.ActivityProvider provider = objectmodel.ActivityProvider();

  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  Map<String,LoadingState> _loadingStates = {};
  Map<String,List<Activity>> myActivities = {};
  bool _isLoading = false;
  String? errormessage;
  List activityTypes = ['activity','location'];
  @override
  void initState() {
    print('Initializing dashboard state');

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      User user = Provider.of<UserProvider>(context, listen: false).user;
      //Check if user has activities available that they can edit / log visits for
     for(var a in activityTypes) {
        _loadMyActivities(user,a);
      }
    });
  }

  /*
  Check if user has activities with MODIFY or greater access, for displaying 'my activities' link
   */
  _loadMyActivities(user,type) async {
    _isLoading = true;
    int offset = 0;
    int limit = 1;
    DateTime now = DateTime.now();
    Map<String, String> params = {
      'activitystatus': 'active',
      'activitytype': type,
      'accesslevel': 'modify',
      'limit': limit.toString(),
      'offset': offset.toString(),
      'api-key': user.token ?? '',
      'api_key': user.token ?? '',
      'sort': 'nexteventdate',
    };
    if(type=='activity') params['startfrom'] = DateFormat('yyyy-MM-dd').format(now);
    try {
      print('checking for user own activities of type '+type);
      var nextActivities = await widget.provider.loadItems(params);
      setState(() {
        print(nextActivities.length.toString()+' items loaded for '+type);
        _loadingStates[type] = LoadingState.DONE;
         List<Activity> loadedActivities= [];
         loadedActivities.addAll(nextActivities);
         myActivities[type] = loadedActivities;
       //myActivities[type].addAll(nextActivities);

        _isLoading = false;
      });
    } catch (e, stack) {
      _isLoading = false;
      print('loadItems returned error $e\n Stack trace:\n $stack');
      errormessage = e.toString();
      if (_loadingStates[type] == LoadingState.LOADING) {
        setState(() => _loadingStates[type] = LoadingState.ERROR);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    //for debugging, track builds in print
    print('building dasboard state');
    AuthProvider auth = Provider.of<AuthProvider>(context);
    User user = Provider.of<UserProvider>(context).user;
/*
    if (user.token == null) {
      print('user token not found, pushing named route /login');
      return Login();
    } else */{
      print('Current token: ' +
          user.token.toString() +
          ', id: ' +
          user.id.toString());
      objectmodel.ActivityProvider provider = objectmodel.ActivityProvider();
      objectmodel.ImageProvider imageprovider = objectmodel.ImageProvider();

      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.youthcardDashboard),
          elevation: 0.1,
          actions: [
            IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  print('Refreshing view');
                  setState(() {

                    _loadingStates.forEach((key, value) {
                      _loadingStates[key] = LoadingState.LOADING;
                    });
                    _isLoading = false;
                    for(var a in activityTypes) {
                      _loadMyActivities(user,a);
                    }
                  });
                }),
            InkWell(
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: user.image != null && user.image!.isNotEmpty
                      ? CachedNetworkImageProvider(user.image!)
                      : null,
                  child: user != null ? getInitials(user) : Container(),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyCard()),
                  );
                }),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("images/splash.png"), fit: BoxFit.cover),
          ),
          constraints: BoxConstraints.expand(),
          child: GridView.count(
            // Create a grid with 2 columns. If you change the scrollDirection to
            // horizontal, this produces 2 rows.
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            padding: EdgeInsets.only(top: 10,left:20,right:20),
            children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: MaterialButton(
                  //padding: EdgeInsets.all(8.0),
                  textColor: Colors.white,
                  splashColor: Colors.greenAccent,
                  // elevation: 8.0,
                  child: Stack(children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: (user.image != null && user.image!.isNotEmpty
                              ? CachedNetworkImageProvider(user.image!)
                              : AssetImage('images/profile.png')
                                  as ImageProvider),
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
                      child: Text(AppLocalizations.of(context)!.myCard),
                    ),
                  ]),
                  // ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyCard()),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: ClipOval(
                  child: Material(
                    color: Theme.of(context).primaryColor, // button color
                    child: InkWell(
                      splashColor: Colors.green, // splash color
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => QRScanner()),
                        );
                      }, // button pressed
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.qr_code,
                              size: 40, color: Colors.white), // icon
                          Text(AppLocalizations.of(context)!.qrScanner,
                              style: TextStyle(color: Colors.white)), // text
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: ClipOval(
                  child: Material(
                    color: Theme.of(context).primaryColor, // button color
                    child: InkWell(
                      splashColor: Colors.green, // splash color
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ActivityCalendar(provider, imageprovider)),
                        );
                      }, // button pressed
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.calendar_today,
                              size: 40, color: Colors.white), // icon
                          Text(AppLocalizations.of(context)!.calendar,
                              style: TextStyle(color: Colors.white)), // text
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: ClipOval(
                  child: Material(
                    color: Theme.of(context).primaryColor, // button color
                    child: InkWell(
                      splashColor: Colors.green, // splash color
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  CategorisedActivityList(imageprovider)),
                        );
                      }, // button pressed
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.search,
                            size: 40,
                            color: Colors.white,
                          ), // icon
                          Text(AppLocalizations.of(context)!.discover,
                              style: TextStyle(color: Colors.white)), // text
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: ClipOval(
                  child: Material(
                    color: Theme.of(context).primaryColor, // button color
                    child: InkWell(
                      splashColor: Colors.green, // splash color
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SettingsScreen()),
                        );
                      }, // button pressed
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.settings, size: 40, color: Colors.white),
                          // icon
                          Text(AppLocalizations.of(context)!.settings,
                              style: TextStyle(color: Colors.white)),
                          // text
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: ClipOval(
                  child: Material(
                    color: Theme.of(context).primaryColor, // button color
                    child: InkWell(
                      splashColor: Colors.green, // splash color
                      onTap: () {
                        UserPreferences().removeUser();
                        Provider.of<UserProvider>(context, listen: false)
                            .clearUser();
                        Navigator.pushReplacementNamed(context, '/login');
                      }, // button pressed
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.logout,
                            size: 40,
                            color: Colors.white,
                          ), // icon
                          Text(AppLocalizations.of(context)!.logout,
                              style: TextStyle(color: Colors.white)), // text
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              myActivitiesListLink(user, provider, imageprovider),
              myLocationsListLink(user, provider, imageprovider),

            ],
          ),
        ),
      );
    }
  }

  Widget myLocationsListLink(user, userprovider, imageprovider) {

    switch (_loadingStates['location']) {
      case LoadingState.DONE:
      //data loaded
      bool hascontent = myActivities['location']!=null ? myActivities['location']!.isNotEmpty : false;
        if (hascontent) {

          return Padding(
            padding: EdgeInsets.all(20),
            child: ClipOval(
              child: Material(
                color: Theme
                    .of(context)
                    .primaryColor, // button color
                child: InkWell(
                  splashColor: Colors.green, // splash color
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ActivityList(
                                  userprovider, imageprovider,
                                  viewType: 'locations')),
                    );
                  }, // button pressed
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.house_outlined, size: 40, color: Colors.white),
                      // icon
                      Text(AppLocalizations.of(context)!.locations,
                          style: TextStyle(color: Colors.white)),
                      // text
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        else {
          print('not printing locations button');
          return Container();
        }

      case LoadingState.LOADING:
      //data loading in progress
        if (!_isLoading) _loadMyActivities(user,'location');
        return ElevatedButton(
            onPressed: () {}, child: CircularProgressIndicator());

      default:
        return Container();
    } //switch
  }

  Widget myActivitiesListLink(user, userprovider, imageprovider) {
    switch (_loadingStates['activity']) {
      case LoadingState.DONE:
        //data loaded
        if (myActivities['activity']?.isNotEmpty?? false) {
          print('displaying my activities button');
          return Padding(
              padding: EdgeInsets.all(20),
              child:ClipOval(
            child: Material(
              color: Theme.of(context).primaryColor, // button color
              child: InkWell(
                splashColor: Colors.green, // splash color
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ActivityList(
                            userprovider, imageprovider,
                            viewType: 'own')),
                  );
                }, // button pressed
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.list_alt_outlined, size: 40, color: Colors.white),
                    // icon
                    Text(AppLocalizations.of(context)!.myActivities,
                        style: TextStyle(color: Colors.white)),
                    // text
                  ],
                ),
              ),
            ),
              ),
          );
        } else {
          return Container();
        }

      case LoadingState.LOADING:
        //data loading in progress
        if (!_isLoading) _loadMyActivities(user,'activity');
        return ElevatedButton(
            onPressed: () {}, child: CircularProgressIndicator());

      default:
        return Container();
    } //switch
  }
}
