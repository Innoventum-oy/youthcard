import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:youth_card/src/objects/activityvisit.dart';
import 'package:youth_card/src/objects/webpage.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/providers/webpageprovider.dart';
import 'package:youth_card/src/util/api_client.dart';
import 'package:youth_card/src/objects/activity.dart';
import 'package:youth_card/src/providers/objectprovider.dart' as objectmodel;
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/util/utils.dart';
import 'package:youth_card/src/views/card.dart';
import 'package:youth_card/src/views/webpagetextcontent.dart';

class ActivityVisitList extends StatefulWidget {
  final String viewTitle = 'activityvisitlist';
  final Activity _activity;
  final objectmodel.ActivityVisitListProvider visitListProvider = objectmodel.ActivityVisitListProvider();
  ActivityVisitList(this._activity);

  @override
  _ActivityVisitListState createState() =>
      _ActivityVisitListState();
}
class _ActivityVisitListState extends State<ActivityVisitList> {

  User user = new User();
  WebPage page = new WebPage();
  List<ActivityVisit> visits=[];
  List<User> users = [];
  @override
  void initState() {
    print('initState '+widget.viewTitle);
    this.user = Provider.of<UserProvider>(context,listen:false).user;
    widget.visitListProvider.setUser(this.user);

    //See if info page exists for the view
    updateUsers();
    super.initState();
  }
  void updateUsers() async
  {
    print('updateUsers called!');
    List<ActivityVisit> visits = ( await widget.visitListProvider.loadActivityVisits(widget._activity)) as List<ActivityVisit>;
    setState((){
      print('setState called!');
      this.visits = visits;

    });
  }
  @override
  void didChangeDependencies() {
    print('didChangeDepenencies '+widget.viewTitle);
    Provider.of<WebPageProvider>(context,listen:false).loadItem({'language' : Localizations.localeOf(context).toString(),
      'commonname': widget.viewTitle,
      'fields' :'id,commonname,pagetitle,textcontents',
      if(user.token!=null) 'api_key': user.token,});
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
    //current user
    print('build '+widget.viewTitle);

    this.page = Provider.of<WebPageProvider>(context).page;
    visits = widget.visitListProvider.list ?? [];

    // Future<List<ActivityVisit>?> getVisits() => widget.visitListProvider.loadActivityVisits(widget._activity);
    bool hasInfoPage = this.page.id != null ? true : false;
    bool isTester = false;
    print('VISITS '+visits.length.toString());
    if(user.data!=null) {
      if (user.data!['istester'] != null) {
        if (user.data!['istester'] == 'true') isTester = true;
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget._activity.name!+': '+AppLocalizations.of(context)!.eventLog),
        elevation: 0.1,
        actions: [
          if(hasInfoPage)IconButton(
              icon: Icon(Icons.info_outline_rounded),
              onPressed:(){
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ContentPageView(widget.viewTitle,providedPage:this.page),
                ));}
          ),
          if(isTester) IconButton(
              icon: Icon(Icons.bug_report),
              onPressed:(){feedbackAction(context,user); }
          ),
          IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                print('Refreshing view');
                setState(() {
                  //TODO refresh visit list. Also to implement timer to scan for updates!

                });

                Provider.of<WebPageProvider>(context,listen:false).refresh(user);
              })
        ],
      ),
      body:  ListView.builder(
          itemCount: visits.length,
          itemBuilder: (BuildContext context, int index) {
            ActivityVisit visit = visits[index];
            print('loading data for user '+visit.userid!.toString() );
            Future<User> userdata = visit.userprovider!.loadUser(visit.userid ?? 0, this.user);

            return FutureBuilder(
                initialData: new User(),
                future: userdata,
                builder: (context, AsyncSnapshot snapshot){

                  var titleDateFormat = new DateFormat('dd.MM hh:mm');
                  if(snapshot.data==null){
                    return ListTile(
                      leading: Icon(Icons.error),
                      title: Text(titleDateFormat.format(visit.startdate?? DateTime.now()).toString()+': '+AppLocalizations.of(context)!.userNotFound),
                    );
                  }
                  if(snapshot.data.id!=null ){

                    User user = snapshot.data;

                    return ListTile(
                      leading: InkWell(
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: user.data!['userimageurl'] != null && user.data!['userimageurl']!.isNotEmpty
                                ? CachedNetworkImageProvider(user.data!['userimageurl']!)
                                : null,
                            child: getInitials(user),
                          ),
                          onTap: () {
                             Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MyCard(user:user)),
                            );

                          }),
                      title: Text(titleDateFormat.format(visit.startdate?? DateTime.now()).toString()+': '+user.fullname),
                      subtitle: user.userbenefits.isNotEmpty ? Container(
                          height: 30,
                          //padding: EdgeInsets.only(left: 10, right: 10),
                          child: GridView.builder(
                              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 120,
                              ),
                              itemCount: user.userbenefits.length,
                              itemBuilder: (BuildContext context, int index) {
                                return _userBenefitListItem(user.userbenefits[index]);
                              }),
                        )
                      : Text(AppLocalizations.of(context)!.noActiveBenefits),
                    );
                  }
                  else {

                    return ListTile(
                      leading: CircularProgressIndicator(),
                      title: Text(titleDateFormat.format(visit.startdate?? DateTime.now()).toString()+': '+AppLocalizations.of(context)!.loading),
                    );
                  }
                }
            );
          }
      ),
    );

  }

  Widget _userBenefitListItem(benefit) {
    return Container(
        child: Column(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(benefit.iconurl),
              backgroundColor: Colors.white10,
              radius: 20.0,
            ),
            Text(benefit.title ?? AppLocalizations.of(context)!.unnamed)
          ],
        ));
  }

}