import 'package:flutter/material.dart';
import 'package:youth_card/src/objects/activity.dart';
import 'package:youth_card/src/objects/activityclass.dart';
import 'package:youth_card/l10n/app_localizations.dart';
import 'package:youth_card/src/providers/index.dart' as object_model;
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/util/utils.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:youth_card/src/util/navigator.dart';

class ActivityListSliver extends StatefulWidget {
  final object_model.ActivityListProvider activityProvider;
  final object_model.ImageProvider imageProvider;
  final ActivityClass activityClass;

  const ActivityListSliver(
      this.activityProvider, this.imageProvider, this.activityClass, {super.key});

  @override
  ActivityListSliverState createState() => ActivityListSliverState();
}

class ActivityListSliverState extends State<ActivityListSliver> {
  Map<String, dynamic>? map;
  List<Activity> data = [];
  User? user;
  LoadingState _loadingState = LoadingState.loading;
  bool _isLoading = false;
  int iteration = 1;
  int buildtime = 1;
  int limit = 20;
  int count = 0;
  int _pageNumber = 0;
  String? errormessage;

  notify(String text) {
    final snackBar = SnackBar(
      content: Text(text),
    );

    // Find the ScaffoldMessenger in the widget tree
    // and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  int calculateDifference(DateTime date) {
    DateTime now = DateTime.now();
    return DateTime(date.year, date.month, date.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
  }

  _loadNextPage(user, activityclass) async {
    _isLoading = true;
    int offset = limit * _pageNumber;
    DateTime now = DateTime.now();
    final Map<String, String> params = {
      'view':'activitylistsliver',
      'activityclass': activityclass.id.toString(),
      'activitystatus': 'active',
      'activitytype': 'activity',
      'grouping':'activity.id',
      'limit': limit.toString(),
      'offset': offset.toString(),
      'startfrom': DateFormat('yyyy-MM-dd').format(now),
      if(user.token !=null) 'api_key': user.token,
      if(user.token !=null) 'api_key': user.token,

      'sort': 'nexteventdate',
    };

    try {
      var nextActivities = await widget.activityProvider.loadItems(params);
      setState(() {
        _loadingState = LoadingState.done;
        if (nextActivities.isNotEmpty) {
          data.addAll(nextActivities);
          if (nextActivities.length >= limit) {
            _isLoading = false;
            _pageNumber++;
          }
        }
        else {
        }
      });
    } catch (e) {
      _isLoading = false;
      errormessage = e.toString();
      if (_loadingState == LoadingState.loading) {
        setState(() => _loadingState = LoadingState.error);
      }
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      User user = Provider.of<UserProvider>(context, listen: false).user;

      _loadNextPage(user, widget.activityClass);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context, listen: false).user;

    return _getContentSection(user);
  }

  Widget _getContentSection(user) {
    switch (_loadingState) {
      case LoadingState.done:
        if(data.isEmpty) {
          return Container(
          padding: EdgeInsets.all(20),
          child:
          ListTile(
            leading: Icon(Icons.error,color:Colors.white),
            title: Text(
                AppLocalizations.of(context)!.noActivitiesFound,
                style:TextStyle(color:Colors.white)),
          ),
        );
        }
        return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            scrollDirection: Axis.horizontal,
            itemCount: data.length,
            itemBuilder: (BuildContext context, int index) {
              if (!_isLoading && index > (data.length * 0.7)) {
                _loadNextPage(user, widget.activityClass);
              }

              return activityHorizontal(data[index]);
            });

      case LoadingState.error:
        //data loading returned error state
        return Align(
          alignment: Alignment.center,
          child: ListTile(
            leading: Icon(Icons.error),
            title: Text(
                'Sorry, there was an error loading the data: $errormessage'),
          ),
        );

      case LoadingState.loading:
        //data loading in progress
        return Align(
          alignment: Alignment.center,
          child: Center(
            child: ListTile(
              leading: CircularProgressIndicator(),
              title: Text(AppLocalizations.of(context)!.loading,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        );
      default:
        return Text('No activities found in this category');
    }
  }

  Widget activityHorizontal(activity) {
    List<Widget> buttons = [];
    buttons.add(TextButton(
      child: Text(AppLocalizations.of(context)!.readMore),
      onPressed: () {
        /* open library view */
        goToActivity(context, activity);
      },
    ));
    buttons.add(const SizedBox(width: 8));

    if (activity.accesslevel >= 20) {
      //user has modify access
    }

    String dateinfo = activity.nexteventdate == null
        ? ''
        : (calculateDifference(activity.nexteventdate!) != 0
            ? DateFormat('kk:mm dd.MM.yyyy').format(activity.nexteventdate!)
            : AppLocalizations.of(context)!.today + DateFormat('kk:mm ').format(activity.startdate!));

    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.0),
        child: InkWell(
            onTap: () => goToActivity(context, activity),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Card(
                    elevation: 18.0,
                    child: activity.coverpictureurl != null
                        ? Image.network(activity.coverpictureurl!,
                            width: 150, height: 230, fit: BoxFit.cover)
                        : widget.activityClass.coverpictureurl != null
                            ? Image.network(
                                widget.activityClass.coverpictureurl!,
                                width: 150,
                                height: 230,
                                fit: BoxFit.cover)
                            : Icon(Icons.group_rounded, size: 150),
                  ),
                  Text(
                      (activity.name ?? AppLocalizations.of(context)!.unnamedActivity)!,
                      style: TextStyle(color: Colors.white)),
                  Text(dateinfo, style: TextStyle(color: Colors.white)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: buttons,
                  ),
                ])));
  }
}
