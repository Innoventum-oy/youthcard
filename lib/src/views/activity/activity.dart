import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:youth_card/src/objects/activity.dart';
import 'package:youth_card/src/objects/activitydate.dart';
import 'package:youth_card/src/providers/objectprovider.dart' as objectmodel;
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/util/navigator.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:youth_card/src/util/api_client.dart';
import 'package:youth_card/src/util/styles.dart';
import 'package:youth_card/src/views/utilviews.dart';
import 'package:youth_card/src/views/meta_section.dart';
import 'package:youth_card/src/views/qrscanner.dart';
import 'package:youth_card/src/views/activity/activityparticipantlist.dart';
class ActivityView extends StatefulWidget {
  final Activity _activity;
  final objectmodel.ActivityProvider provider;
  final objectmodel.ImageProvider imageprovider;

  ActivityView(this._activity, this.provider, this.imageprovider);

  @override
  _ActivityViewState createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> {
  final ApiClient _apiClient = ApiClient();
  Map<String, dynamic>? map;
  List<ActivityDate> activityDates = [];

  int iteration = 1;
  int buildtime = 1;
  bool _visible = false;
  bool _activityDatesLoaded = false;
  User? user;
  dynamic _activityDetails; // this is json data, not converted to activity object!

  int calculateDifference(DateTime date) {
    DateTime now = DateTime.now();
    return DateTime(date.year, date.month, date.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
  }

  Notify(String text) {
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

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      User user = Provider.of<UserProvider>(context, listen: false).user;
      print('running addPostFrameCallback (initstate');
      _loadDetails(user);
      if (widget._activity.accesslevel >= 20)  _loadActivityDates(user);
    });

   // Timer(Duration(milliseconds: 100), () => setState(() => _visible = true));
  }

  @override
  Widget build(BuildContext context) {
    print('rebuilding activity view');
    final user = Provider.of<UserProvider>(context, listen: false).user;
    return Scaffold(
        appBar: AppBar(
            title: Text(widget._activity.name?? AppLocalizations.of(context)!.activity),
            elevation: 0.1,
            actions: [
          IconButton(
          icon: Icon(Icons.refresh),
          onPressed: () {
            print('Refreshing view');
            setState(() {
              _loadDetails(user,reload:true);
            });
          }),
        ],
        ),
        backgroundColor: primary,
        body: CustomScrollView(
          slivers: <Widget>[
            _buildAppBar(widget._activity),
            _buildContentSection(widget._activity),
          ],
        ));
  }

  List<Widget> buttons(Activity activity) {
    print('building buttons');
    final user = Provider.of<UserProvider>(context, listen: false).user;
    List<Widget> buttons = [];

    if (activity.registration || activity.registration=='true') {
      print('registration is enabled for activity');
      buttons.add(ElevatedButton(
        child: Text(AppLocalizations.of(context)!.signUp),
        onPressed: () {
          print('signing up for activity {$activity.name}');
          _apiClient.registerForActivity(activity.id, user);
        },
      ));

      buttons.add(const SizedBox(width: 8));
    }else print('registration not enabled for activity :'+activity.registration.toString());
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
      buttons.add(const SizedBox(width: 8));
    }
    return buttons;
  }

  Widget _buildAppBar(Activity activity) {
    return SliverAppBar(
      expandedHeight: 240.0,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Hero(
              tag: "Activity-Tag-${widget._activity.id}",
              child: widget._activity.coverpictureurl != null
                  ? FadeInImage.assetNetwork(
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: 'images/activity-placeholder.png',
                      image: widget._activity.coverpictureurl!,
                    )
                  : Image(image: AssetImage('images/activity-placeholder.png')),
            ),
            BottomGradient(),
            //_buildMetaSection(activity)
          ],
        ),
      ),
    );
  }

  Widget _buildMetaSection(Activity activity) {

    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: Duration(milliseconds: 500),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                TextBubble(
                  activity.startdate.toString(),
                  backgroundColor: Color(0xffF47663),
                ),
                /*  Container(
                  width: 8.0,
                ),
                TextBubble(activity.voteAverage.toString(),
                    backgroundColor: Color(0xffF47663)),

               */
              ],
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(activity.name!,
                  style: TextStyle(color: Color(0xFFEEEEEE), fontSize: 20.0)),
            ),
            /*
            Row(

              children: getGenresForIds(mediaItem.genreIds)
                  .sublist(0, min(5, mediaItem.genreIds.length))
                  .map((genre) => Row(
                children: <Widget>[
                  TextBubble(genre),
                  Container(
                    width: 8.0,
                  )
                ],
              ))
                  .toList(),
            )
          */
          ],
        ),
      ),
    );
  }

  void _loadDetails(user,{bool reload:false}) async {
    print('called _loadDetails for activity ' +
        widget._activity.id.toString() +
        ', awaiting provider for details!');
    try {
      dynamic details =
          await widget.provider.getDetails(widget._activity.id!, user,reload:reload);
      //print(details.toString());
      // print(details.runtimeType);

      setState(() =>_activityDetails =details!=null ? details.first:false);
    } catch (e, stack) {
      print('loadDetails returned error $e\n Stack trace:\n $stack');
      //Notify(e.toString());
      e.toString();
    }
  }

  void _loadActivityDates(user) async {
    try {
      var activityDateData =
          await widget.provider.getActivityDates(widget._activity, user);

      setState(() {
        _activityDatesLoaded = true;
        if (activityDateData.isNotEmpty) {
          activityDates.addAll(activityDateData);
          print(activityDates.length.toString() + ' activity dates loaded');
        } else {
          print('no more activities were found');
        }
      });
    } catch (e, stack) {
      print('loadActivityDates returned error $e\n Stack trace:\n $stack');
      //Notify(e.toString());
      e.toString();
    }
  }
  Widget ActivityDateRow(date,activity)
  {
    String dateinfo = date.startdate == null
        ? ''
        : (calculateDifference(date.startdate!) != 0
        ? DateFormat('kk:mm dd.MM.yyyy')
        .format(date.startdate!)
        : 'Today ' +
        DateFormat('kk:mm ').format(date.startdate!));
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
            : 'Today ' + DateFormat('kk:mm ').format(activity.nexteventdate!));
    double dateSectionHeight = activityDates.length*80;
    if(dateSectionHeight > 400) dateSectionHeight = 400;
    List<Widget> slivers = [
      Container(
        decoration: BoxDecoration(color: const Color(0xff222128)),
        child: Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                activity.name != null
                    ? activity.name.toString()
                    : AppLocalizations.of(context)!.unnamedActivity,
                style: const TextStyle(color: Colors.white),
              ),
              Container(
                height: 8.0,
              ),
              Text(dateinfo, style: const TextStyle(color: Colors.white)),
              Container(
                height: 8.0,
              ),
              Text(activity.description!,
                  style:
                  const TextStyle(color: Colors.white, fontSize: 12.0)),
              Container(
                height: 8.0,
              ),
              Row(
                children: buttons(activity),
              )
            ],
          ),
        ),
      ),
    ];

    if(activity.accesslevel >=20)
      slivers.add(
        Container(
          height: dateSectionHeight,
          decoration: BoxDecoration(color: primaryDark),
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


                return ActivityDateRow(date,activity);
              }),
          //),
        ),

      );

    slivers.add(Container(
      decoration: BoxDecoration(color: primaryDark),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _activityDetails == null
            ? Center(
          child: ListTile(
            leading: CircularProgressIndicator(),
            title: Text(AppLocalizations.of(context)!.loading,
                textAlign: TextAlign.center),
          ),
        )
            : MetaSection(_activityDetails),
      ),
    ));
    return SliverList(
      delegate: SliverChildListDelegate(

       slivers

      ),
    );
  }
}
