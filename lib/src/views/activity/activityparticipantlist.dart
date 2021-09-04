import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:youth_card/src/objects/activity.dart';
import 'package:youth_card/src/objects/activitydate.dart';
import 'package:youth_card/src/providers/objectprovider.dart' as objectmodel;
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:youth_card/src/util/api_client.dart';


class ActivityParticipantList extends StatefulWidget {
  final ActivityDate _activityDate;
  final Activity _activity;
  final objectmodel.ActivityProvider activityProvider;

  ActivityParticipantList(this._activityDate,this._activity, this.activityProvider);

  @override
  _ActivityParticipantListState createState() =>
      _ActivityParticipantListState();
}

class _ActivityParticipantListState extends State<ActivityParticipantList> {
  final ApiClient _apiClient = ApiClient();
  bool userListLoaded = false;
  bool visitListLoaded = false;
  List<User> users = [];
  Map<dynamic,String> activityVisitData ={};
  notify(String text) {
    final snackBar = SnackBar(
      content: Text(text),
    );

    // Find the ScaffoldMessenger in the widget tree
    // and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _loadActivityUsers(activityDate,user) async {
    try {
      var activityUserData =
      await widget.activityProvider.getActivityUsers(widget._activity.id!,user);

      setState(() {
        userListLoaded = true;
        if (activityUserData.isNotEmpty) {
          users.addAll(activityUserData);
          print(activityUserData.length.toString() + ' users loaded');
          _loadActivityVisits(widget._activity.id!,widget._activityDate,user);
        } else {
          print('no users found for activity');
        }
      });
    } catch (e, stack) {
      print('loadActivityUsers returned error $e\n Stack trace:\n $stack');
      //Notify(e.toString());
      e.toString();
    }
  }
  void _loadActivityVisits(activity,activitydate,user) async {
    try {
      this.activityVisitData =
      await widget.activityProvider.getActivityDateVisits(widget._activity.id!,activitydate,user);

      setState(() {
        visitListLoaded = true;
        if (this.activityVisitData.isNotEmpty) {
          print(this.activityVisitData.length.toString() + ' visits loaded');
        } else {
          print('no visit information found for activity');
        }
      });
    } catch (e, stack) {
      print('loadActivityVisits returned error $e\n Stack trace:\n $stack');
      //Notify(e.toString());
      e.toString();
    }
  }
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      User user = Provider.of<UserProvider>(context, listen: false).user;
      _loadActivityUsers(widget._activityDate,user);

    });

   // Timer(Duration(milliseconds: 100), () => setState(() => _visible = true));
  }

  @override
  Widget build(BuildContext context) {
    var titleDateFormat = new DateFormat('dd.MM hh:mm');
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(AppLocalizations.of(context)!.participants+ ' '+(widget._activityDate.startdate !=null ? titleDateFormat.format(widget._activityDate.startdate ?? DateTime.now()).toString() : ''))
        ),
        body: userListLoaded ? userList() : Center(child:CircularProgressIndicator(),
        ),
    );

  }
  Widget userList()
  {
    final loggedInUser = Provider.of<UserProvider>(context, listen: false).user;
    if(users.isEmpty)
      return Align(
          alignment: Alignment.center,
          child:Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children:[
              Icon(Icons.info),
              Text(AppLocalizations.of(context)!.noUsersFound,textAlign:TextAlign.center,)
          ]),
      );
    return ListView.builder(
        itemBuilder: (context,index){
          User user = users[index];
      return SwitchListTile(
        value: activityVisitData[user.id.toString()]=='visited' ?true:false,
        title: Text(user.firstname!+' '+user.lastname!),
        subtitle: Text((user.email ?? '')+' '+(user.phone ??'')),
        secondary: Icon(Icons.supervised_user_circle_sharp),
        onChanged: (bool value) async {

            notify(value.toString());
            Map<String,dynamic> result = await _apiClient.updateActivityRegistration(activityId:widget._activity.id!,visitStatus:value ? 'visited':'cancelled',visitor: user,user:loggedInUser,visitDate:widget._activityDate) ;
            setState(() {
            if(result['visitstatus']!=null) {
              print('updatevisit returned visitstatus '+result['visitstatus'].toString()+' for user '+result['userid']);
              activityVisitData[result['userid']] = result['visitstatus'];
              print(activityVisitData);
            }

          });

        }
      );
    },
    itemCount:users.length
    );
  }
}

