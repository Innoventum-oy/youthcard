import 'dart:async';

import 'package:flutter/material.dart';
import 'package:youth_card/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:youth_card/src/objects/activity.dart';
import 'package:youth_card/src/objects/activitydate.dart';
import 'package:youth_card/src/providers/index.dart' as object_model;
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:youth_card/src/util/api_client.dart';
import 'package:youth_card/src/util/utils.dart';
import 'package:youth_card/src/views/activity/activityvisitlist.dart';
import 'package:youth_card/src/views/utilviews.dart';
import 'package:youth_card/src/views/meta_section.dart';
import 'package:youth_card/src/views/qrscanner.dart';
import 'package:youth_card/src/views/activity/activityparticipantlist.dart';
import 'package:youth_card/src/util/activity_thumbnail.dart';
class ActivityView extends StatefulWidget {
  final Activity _activity;
  final object_model.ActivityListProvider provider;
  final object_model.ImageProvider imageprovider;

  const ActivityView(this._activity, this.provider, this.imageprovider, {super.key});

  @override
  ActivityViewState createState() => ActivityViewState();
}

class ActivityViewState extends State<ActivityView> {
  final ApiClient _apiClient = ApiClient();
  Map<String, dynamic>? map;
  List<ActivityDate> activityDates = [];
  Timer? _timer;
  int iteration = 1;
  int buildtime = 1;
  bool _showAllDates = false;
  bool _detailsFailed = false;
  //bool _visible = false;

  User? user;
  Map<String, dynamic>? _activityDetails;

  Activity get _displayActivity {
    final details = _activityDetails;
    if (details == null) return widget._activity;
    try {
      return Activity.fromJson(details);
    } catch (_) {
      return widget._activity;
    }
  }

  int calculateDifference(DateTime date) {
    DateTime now = DateTime.now();
    return DateTime(date.year, date.month, date.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
  }

  void notify(String text) {
    final snackBar = SnackBar(
      content: Text(text),
    );

    // Find the ScaffoldMessenger in the widget tree
    // and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      User user = Provider.of<UserProvider>(context, listen: false).user;

      _loadDetails(user);
      _loadActivityDates(user);
    });

   // Timer(Duration(milliseconds: 100), () => setState(() => _visible = true));
  }

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<UserProvider>(context, listen: false).user;
    bool isTester = false;
    if(user.data!=null) {

      if (user.data!['istester'] != null) {
        if (user.data!['istester'] == 'true') isTester = true;
      }
    }
    return Scaffold(
        appBar: AppBar(
            title: Text(_displayActivity.name?? AppLocalizations.of(context)!.activity),
            elevation: 0.1,
            actions: [
              if(isTester) IconButton(
                  icon: Icon(Icons.bug_report),
                  onPressed:(){feedbackAction(context,user); }
              ),
          IconButton(
          icon: Icon(Icons.refresh),
          onPressed: () {

            _loadDetails(user,reload:true);
            _loadActivityDates(user);
          }),
        ],
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: CustomScrollView(
          slivers: <Widget>[
            _buildAppBar(_displayActivity),
            _buildContentSection(_displayActivity),
          ],
        ));
  }

  List<Widget> buttons(Activity activity) {
   // print('building buttons');
    final user = Provider.of<UserProvider>(context, listen: false).user;
    List<Widget> buttons = [];

    if(activity.registration
        && ( activity.maxvisitors==null || (activity.maxvisitors??0) > (activity.registeredvisitorcount??0) )
        && ( activity.registrationenddate==null || activity.registrationenddate!.isAfter(DateTime.now()))
        && user.token!=null) {


      buttons.add(ElevatedButton(
        child: _apiClient.isProcessing ?  SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
          value: null,
          semanticsLabel: AppLocalizations.of(context)!.loading,
        )) : Text(AppLocalizations.of(context)!.signUp),
        onPressed: () {
          registerForActivity(activity,user);
          setState(() {

          });

        },
      ));


    }
    if (activity.accesslevel >= 20) {
      buttons.add(ElevatedButton(
        child: Text(AppLocalizations.of(context)!.qrScanner),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => QRScanner(activity: activity)));
        },
      ));

      buttons.add(ElevatedButton(
        child: Text(AppLocalizations.of(context)!.eventLog),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ActivityVisitList(activity)));
        },
      ));
    }
    return buttons;
  }

  Widget _buildAppBar(Activity activity) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 240,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Hero(
              tag: "Activity-Tag-${activity.id}",
              child: ActivityThumbnail(
                eventUrl: activity.coverpictureurl,
                categoryId: activity.activityClassId,
                width: double.infinity,
                height: double.infinity,
                borderRadius: BorderRadius.zero,
              ),
            ),
            BottomGradient(),
          ],
        ),
      ),
    );
  }
  void registerForActivity(Activity activity, User user) async
  {

    if (!_apiClient.isProcessing) {

      Map<String,dynamic> result = await _apiClient.registerForActivity(
          activity.id, user);
      if (!mounted) return;
      setState(() {
        switch(result['status'])
        {
          case 'success':
            showMessage(context,AppLocalizations.of(context)!.activityRegistrationSaved ,Text(result['message']));

            break;
          default:
            var message = Column(children:[
              Icon(Icons.error_outline),
              Text(result['message']),
             if (result['errormessage']!=null) Text(result['errormessage'])
            ]);
            showMessage(context, AppLocalizations.of(context)!.activityRegistrationFailed,message);

        }


      });
    }
  }
  void _loadDetails(User user,{bool reload =false}) async {

    try {
      dynamic details =
          await widget.provider.getDetails(widget._activity.id!, user,reload:reload);
      if (!mounted) return;
      setState(() {
        _activityDetails = details is Map
            ? Map<String, dynamic>.from(details['data'] is Map ? details['data'] : details)
            : null;
        _detailsFailed = _activityDetails == null;
      });
    } catch (_) {
      if (mounted) setState(() => _detailsFailed = true);
    }
  }

  void _loadActivityDates(User user) async {
    try {
      var activityDateData =
          await widget.provider.getActivityDates(widget._activity, user);
      if (!mounted) return;
      setState(() {

        activityDates = List<ActivityDate>.from(activityDateData)
          ..sort((a, b) => (a.startdate ?? DateTime(0))
              .compareTo(b.startdate ?? DateTime(0)));
      });
    } catch (_) {
      // The activity details remain available if dates cannot be loaded.
    }
  }
  Widget activityDateRow(ActivityDate date, Activity activity)
  {
    String dateinfo = date.startdate == null
        ? ''
        : (calculateDifference(date.startdate!) != 0
        ? DateFormat('kk:mm dd.MM.yyyy')
        .format(date.startdate!)
        : 'Today ${DateFormat('kk:mm ').format(date.startdate!)}');
    return Center(
        child: Card(
            child: InkWell(
              //onTap: () => goToActivity(context, activityItem),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.event),
                        title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(dateinfo),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ActivityParticipantList(date,activity,widget.provider)));
                                },
                                child:Icon(Icons.table_rows_sharp),
                              ),
                            ]
                        ),
                        //     subtitle: Text(activityItem.description==null ? '' : '\n'+activityItem.description!)),
                      ),
                      /* Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: buttons,
                                        ),*/
                    ]))));
  }
  Widget _buildContentSection(Activity activity) {
    int calculateDifference(DateTime date) {
      DateTime now = DateTime.now();
      return DateTime(date.year, date.month, date.day)
          .difference(DateTime(now.year, now.month, now.day))
          .inDays;
    }

    String dateinfo = activity.nexteventdate == null
        ? ''
        : (calculateDifference(activity.nexteventdate!) != 0
            ? DateFormat('kk:mm dd.MM.yyyy').format(activity.nexteventdate!)
            : 'Today ${DateFormat('kk:mm ').format(activity.nexteventdate!)}');
    double dateSectionHeight = activityDates.length*80;
    if(dateSectionHeight > 400) dateSectionHeight = 400;
    List<Widget> slivers = [
      Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding:
          const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                activity.name != null
                    ? activity.name.toString()
                    : AppLocalizations.of(context)!.unnamedActivity,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary),
              ),
              Container(
                height: 8.0,
              ),
              Text(dateinfo, style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
              if (activity.description?.trim().isNotEmpty == true) ...[
                const SizedBox(height: 12),
                Text(activity.description!.trim(),
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 15.0,
                        height: 1.45)),
                const SizedBox(height: 12),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: buttons(activity),
              )
            ],
          ),
        ),
      ),
    ];

    final today = DateTime.now();
    final upcomingDates = activityDates.where((date) =>
        date.startdate != null &&
        !date.startdate!.isBefore(DateTime(today.year, today.month, today.day)))
        .toList();
    if (upcomingDates.isNotEmpty && activity.accesslevel < 20) {
      final visibleDates = _showAllDates
          ? upcomingDates
          : upcomingDates.take(4).toList();
      final locale = Localizations.localeOf(context).toString();
      slivers.add(Card(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.schedule,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              for (final date in visibleDates)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(children: [
                    const Icon(Icons.event_outlined, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text(
                      DateFormat('EEE d MMM · HH:mm', locale)
                          .format(date.startdate!) +
                          (date.enddate == null ? '' :
                          '–${DateFormat('HH:mm', locale).format(date.enddate!)}'),
                    )),
                  ]),
                ),
              if (upcomingDates.length > 4)
                TextButton(
                  onPressed: () => setState(() => _showAllDates = !_showAllDates),
                  child: Text(_showAllDates
                      ? AppLocalizations.of(context)!.showFewerDates
                      : AppLocalizations.of(context)!.showAllDates),
                ),
            ],
          ),
        ),
      ));
    }

    if(activity.accesslevel >=20) {
      slivers.add(
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          height: dateSectionHeight,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          //child: Padding(
          //  padding: const EdgeInsets.all(16.0),
          child: activityDates.isEmpty
              ? Center(
            child: ListTile(
              leading: CircularProgressIndicator(),
              title: Text(

                  AppLocalizations.of(context)!.loading,
                  textAlign: TextAlign.center),
            ),
          )
              : ListView.builder(
            // padding: const EdgeInsets.all(8),
              itemCount: activityDates.length,
              itemBuilder: (BuildContext context, int index) {
                ActivityDate date = activityDates[index];


                return activityDateRow(date,activity);
              }),
          //),
        ),

      );
    }

    slivers.add(Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _activityDetails == null && !_detailsFailed
            ? Center(
          child: ListTile(
            leading: CircularProgressIndicator(),
            title: Text(AppLocalizations.of(context)!.loading,
                textAlign: TextAlign.center),
          ),
        )
            : _detailsFailed && _activityDetails == null
                ? Text(AppLocalizations.of(context)!.networkError)
                : MetaSection(_activityDetails),
      ),
    ));
    return SliverList(
      delegate: SliverChildListDelegate(

       slivers

      ),
    );
  }

  void showMessage(BuildContext context, String title, Widget content) {
    showDialog(context: context, builder: (BuildContext builderContext) {
      _timer = Timer(Duration(seconds: 5), () {
        Navigator.of(context).pop();
      });

      return AlertDialog(
        //backgroundColor: Colors.red,
        title: Text(title),
        content: SingleChildScrollView(
          child: content,
        ),
      );
    }
    ).then((val) {
      if (_timer!.isActive) {
        _timer!.cancel();
      }
    });
  }
}
