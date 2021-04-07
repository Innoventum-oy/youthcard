import 'package:flutter/material.dart';
import 'package:youth_card/src/objects/activity.dart';
//import 'package:http/http.dart' as http;
import 'package:youth_card/src/providers/objectprovider.dart' as objectmodel;
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/providers/user_provider.dart';
//import 'package:youth_card/src/util/app_url.dart';
//import 'package:youth_card/src/views/activitylist_item.dart';
import 'dart:async';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:youth_card/src/util/api_client.dart';
import 'package:youth_card/src/util/styles.dart';
import 'package:youth_card/src/views/utilviews.dart';
import 'package:youth_card/src/views/meta_section.dart';

class ActivityView extends StatefulWidget {
  final Activity _activity;
  final objectmodel.ActivityProvider provider;
  final objectmodel.ImageProvider imageprovider;

  ActivityView(this._activity,this.provider,this.imageprovider);

  @override
  _ActivityViewState createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> {
  final ApiClient _apiClient = ApiClient();
  Map<String, dynamic> map;


  int iteration = 1;
  int buildtime = 1;
  bool _visible = false;
  User user;
  dynamic _activityDetails;

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

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      print('addpostFrameCallback called');
      User user = Provider.of<UserProvider>(context,listen: false).user;

      _loadDetails(user);
    });

    Timer(Duration(milliseconds: 100), () => setState(() => _visible = true));
  }

  @override
  Widget build(BuildContext context) {
  final user = Provider.of<UserProvider>(context,listen:false).user;
    return Scaffold(
        backgroundColor: primary,
        body: CustomScrollView(
          slivers: <Widget>[
            _buildAppBar(widget._activity),
            _buildContentSection(widget._activity),
          ],
        ));
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
              child: widget._activity.coverpictureurl != null ? FadeInImage.assetNetwork(
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: 'images/activity-placeholder.png',
                   image:  widget._activity.coverpictureurl ,
              ) : Image(image:AssetImage('images/activity-placeholder.png')),
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
              child: Text(activity.name,
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

  void _loadDetails(user) async {
    try {

      dynamic details = await widget.provider.getDetails(widget._activity.id,user);
      setState(() => _activityDetails = details);
    } catch (e) {
      Notify(e.toString());
      e.toString();
    }
  }
  Widget _buildContentSection(Activity activity) {
    return SliverList(
      delegate: SliverChildListDelegate(<Widget>[
        Container(
          decoration: BoxDecoration(color: const Color(0xff222128)),
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  activity.name,
                  style: const TextStyle(color: Colors.white),
                ),
                Container(
                  height: 8.0,
                ),
                Text(activity.description,
                    style:
                    const TextStyle(color: Colors.white, fontSize: 12.0)),
                Container(
                  height: 8.0,
                ),
              ],
            ),
          ),
        ),

        Container(
          decoration: BoxDecoration(color: primaryDark),
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _activityDetails == null
                  ? Center(
                child: CircularProgressIndicator(),
              )
                  : MetaSection(_activityDetails)),
        ),


      ]),
    );
  }
}