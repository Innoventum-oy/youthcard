import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:youth_card/src/objects/activityvisit.dart';
import 'package:youth_card/src/objects/webpage.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/providers/webpageprovider.dart';
import 'package:youth_card/src/objects/activity.dart';
import 'package:youth_card/src/providers/objectprovider.dart' as objectmodel;
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/util/utils.dart';
import 'package:youth_card/src/views/card.dart';
import 'package:youth_card/src/views/webpagetextcontent.dart';
import 'package:date_range_form_field/date_range_form_field.dart';

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
  Map<int,User> _users = {};
  DateTimeRange myDateRange = DateTimeRange(
      start: DateTime.now().subtract(Duration(days:7)),
      end: DateTime.now()
  );

  @override
  void initState() {
    print('initState '+widget.viewTitle);
    this.user = Provider.of<UserProvider>(context,listen:false).user;
    widget.visitListProvider.setUser(this.user);



    updateUsers();
    super.initState();
  }
  void updateUsers() async
  {
    print('updateUsers called!');
    List<ActivityVisit> visits = ( await widget.visitListProvider.loadActivityVisits(widget._activity,loadParams:{'startdate':DateFormat('yyyy-MM-dd').format(myDateRange.start),'enddate':DateFormat('yyyy-MM-dd').format(myDateRange.end)})) as List<ActivityVisit>;
    setState((){
      print('setState called!');
      this.visits = visits;

    });
  }
  @override
  void didChangeDependencies() {
    print('didChangeDepenencies '+widget.viewTitle);
    //See if info page exists for the view
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
                updateUsers();


              })
        ],
      ),
      body:Column(
        children:[
          //date range picker
          SafeArea(
            child: DateRangeField(
                firstDate: DateTime(2017),
                enabled: true,
                initialValue: this.myDateRange,
                decoration: InputDecoration(
                  labelText: 'Date Range',
                  prefixIcon: Icon(Icons.date_range),
                  hintText: 'Please select a start and end date',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.end.isAfter(DateTime.now())) {
                    return 'Please enter an earlier end date';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    print('daterange changed');
                    myDateRange = value!;
                    updateUsers();
                  });
                }),
          ),
          //results
    visits.isNotEmpty ? Expanded(child:ListView.builder(
        shrinkWrap: true,
          itemCount: visits.length,
          itemBuilder: (BuildContext context, int index) {
            ActivityVisit visit = visits[index];

            if(this._users.isNotEmpty && this._users.containsKey(visit.userid) )
            {
             // print('USER already on list!');
              User user = this._users[visit.userid]!;
              return userListTile(visit,user);
           }
            print('loading data for user '+visit.userid!.toString() );
            Future<User> userdata = visit.userprovider!.loadUser(visit.userid ?? 0, this.user);

            return FutureBuilder(
                initialData: new User(),
                future: userdata,
                builder: (context, AsyncSnapshot snapshot){


                  if(snapshot.data==null){
                    var titleDateFormat = new DateFormat('dd.MM HH:mm');
                    return ListTile(
                      leading: Icon(Icons.error),
                      title: Text(titleDateFormat.format(visit.startdate?? DateTime.now())+': '+AppLocalizations.of(context)!.userNotFound),
                    );
                  }
                  if(snapshot.data.id!=null ){

                    User user = snapshot.data;
                    this._users.putIfAbsent(user.id!,()=>user);
                   // if(!users.containsKey(user.id)) users[user.id!] = user;

                    return userListTile(visit,user);
                  }
                  else {
                    var titleDateFormat = new DateFormat('dd.MM HH:mm');
                    return ListTile(
                      leading: CircularProgressIndicator(),
                      title: Text(titleDateFormat.format(visit.startdate?? DateTime.now()).toString()+': '+AppLocalizations.of(context)!.loading),
                    );
                  }
                }
            );
          }
      ),) :  ListTile(
          leading: Icon(Icons.info_outline),title:Text(AppLocalizations.of(context)!.noVisitsFound+' '+DateFormat('d.M.y').format(myDateRange.start)+(myDateRange.duration.inDays > 0 ? ' - '+DateFormat('d.M.y').format(myDateRange.end) :''))
      )
     ] ),

    );

  }

  Widget userListTile(ActivityVisit visit, User user)
  {
    var titleDateFormat = new DateFormat('dd.MM HH:mm');
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