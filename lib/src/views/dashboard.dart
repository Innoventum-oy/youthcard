import 'package:flutter/material.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/providers/auth.dart';
import 'package:provider/provider.dart';
import 'package:youth_card/src/views/card.dart';
import 'package:youth_card/src/views/qrscanner.dart';
import 'package:youth_card/src/views/calendar.dart';
import 'package:youth_card/src/objects/activity.dart';
import 'package:youth_card/src/providers/objectprovider.dart' as objectmodel;
import 'package:youth_card/src/views/activitylist.dart';
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
  LoadingState _loadingState = LoadingState.LOADING;
  List<Activity> myActivities =[];
  bool _isLoading = false;
  String? errormessage;

  @override
  void initState(){
    print('Initializing dashboard state');
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {

      User user = Provider.of<UserProvider>(context,listen:false).user;

      _loadMyActivities(user);
    });


  }

  _loadMyActivities(user) async {
    _isLoading = true;
    int offset = 0;
    int limit = 1;
    DateTime now = DateTime.now();
    Map<String, String> params = {
      'activitystatus': 'active',
      'activitytype': 'activity',
      'accesslevel' : 'modify',
      'limit' : limit.toString(),
      'offset' : offset.toString(),
      'startfrom' : DateFormat('yyyy-MM-dd').format(now),
      'api-key':user.token,
      'api_key':user.token,
      'sort' : 'nexteventdate',
    };
    try {
    print('checking for user own activities');
      var nextActivities =
      await widget.provider.loadItems(params);
      setState(() {
        _loadingState = LoadingState.DONE;
        myActivities.addAll(nextActivities);
        print(myActivities.length.toString()+' own activities currently loaded!');
        _isLoading = false;

      });
    } catch (e,stack) {
      _isLoading = false;
      print('loadItems returned error $e\n Stack trace:\n $stack');
      errormessage = e.toString();
      if (_loadingState == LoadingState.LOADING) {
        setState(() => _loadingState = LoadingState.ERROR);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('building dasboard state');
    AuthProvider auth = Provider.of<AuthProvider>(context);
    User user = Provider.of<UserProvider>(context).user;

    if(user.token==null) {
      print('user token not found, pushing named route /login');
      return Login();
    }
    else {
      print('Current token: ' + user.token.toString() + ', id: ' +
          user.id.toString());
      objectmodel.ActivityProvider provider = objectmodel.ActivityProvider();
      objectmodel.ImageProvider imageprovider = objectmodel.ImageProvider();
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.youthcardDashboard),
          elevation: 0.1,
          actions: [
            IconButton(
                icon: user.image != null && user.image!.isNotEmpty ? Image.network(
                    user.image!, height: 50) : Image.asset(
                    'images/profile.png'),
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
          padding: EdgeInsets.only(
              top: 10
          ),
          children: [
            MaterialButton(
              //padding: EdgeInsets.all(8.0),
              textColor: Colors.white,
              splashColor: Colors.greenAccent,
              // elevation: 8.0,
              child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: (user.image != null && user.image!.isNotEmpty ?
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

            ElevatedButton(onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QRScanner()),
              );
            }, child: Text(AppLocalizations.of(context)!.qrScanner),

            ),

            ElevatedButton(onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>
                    ActivityCalendar(provider, imageprovider)),
              );
            }, child: Text(AppLocalizations.of(context)!.calendar),
            ),

            ElevatedButton(onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>
                    ActivityList(provider, imageprovider)),
              );
            }, child: Text(AppLocalizations.of(context)!.discover),),

            ElevatedButton(onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            }, child: Text(AppLocalizations.of(context)!.settings),),

            ElevatedButton(onPressed: () {
              // auth.logout(user);
              UserPreferences().removeUser();
              Provider.of<UserProvider>(context, listen: false).clearUser();

              //Navigator.pushNamed(context, '/login');

            }, child: Text(AppLocalizations.of(context)!.logout),),
            myActivitiesListLink(user, provider, imageprovider)
          ],
        ),

      );
    }
  }
  Widget myActivitiesListLink(user,userprovider,imageprovider)
  {
    switch (_loadingState)
    {
      case LoadingState.DONE:
      //data loaded
      if(myActivities.length>0)
        return  ElevatedButton(onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ActivityList(userprovider,imageprovider,viewtype:'own')),
          );

        }, child: Text(AppLocalizations.of(context)!.myActivities), );
      else return Container();

      case LoadingState.LOADING:
      //data loading in progress
      if(! _isLoading) _loadMyActivities(user);
       return ElevatedButton(onPressed: (){

        }, child: CircularProgressIndicator()
        );

    default:
   return  Container();
  }//switch
  }
}