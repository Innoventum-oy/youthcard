import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:youth_card/src/objects/formcategory.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/objects/webpage.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:youth_card/src/providers/web_page_provider.dart';
import 'package:youth_card/src/util/widgets.dart';
import 'package:youth_card/src/views/card.dart';
import 'package:youth_card/src/views/formlist.dart';
import 'package:youth_card/src/views/qrscanner.dart';
import 'package:youth_card/src/views/calendar.dart';
import 'package:youth_card/src/objects/activity.dart';
import 'package:youth_card/src/providers/index.dart' as objectmodel;
import 'package:youth_card/src/views/activity/activitylist.dart';
import 'package:youth_card/src/views/activity/categorisedactivitylist.dart';
import 'package:youth_card/l10n/app_localizations.dart';
import 'package:youth_card/src/views/settings.dart';
import 'package:youth_card/src/util/utils.dart';
import 'package:intl/intl.dart';
import 'package:youth_card/src/util/shared_preference.dart';
import 'package:youth_card/src/views/webpagetextcontent.dart';

class DashBoard extends StatefulWidget {
  final String viewTitle = 'dashboard';
  final objectmodel.ActivityListProvider provider =
      objectmodel.ActivityListProvider();

  DashBoard({super.key});

  @override
  DashBoardState createState() => DashBoardState();
}

class DashBoardState extends State<DashBoard> {
  final Map<String, LoadingState> _loadingStates = {};
  Map<String, List<Activity>> myActivities = {};
  List<FormCategory> formCategories = [];
  bool _isLoading = false;
  bool _formsLoading = false;
  String? errormessage;
  List activityTypes = ['activity', 'location'];
  WebPage page = WebPage();
  objectmodel.ImageProvider imageprovider = objectmodel.ImageProvider();
  objectmodel.ActivityListProvider provider =
      objectmodel.ActivityListProvider();

  @override
  void initState() {


    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      initFunction();
    });
    super.initState();
  }
  void initFunction()
  {

    User user = Provider.of<UserProvider>(context, listen: false).user;
    //Check if user has activities available that they can edit / log visits for
    if (user.token != null) {
      for (var a in activityTypes) {
        _loadMyActivities(user, a);
      }
    }
    _loadForms(user);
    //See if info page exists for the view
    _loadWebPage(user);

  }
  /* load related page */
  _loadWebPage(user)async {

    await Provider.of<WebPageProvider>(context,listen:false).loadItem({
      'language': Localizations.localeOf(context).toString(),
      'commonname': widget.viewTitle,
      'fields': 'id,commonname,pagetitle,textcontents,thumbnailurl',
      if (user.token != null) 'api_key': user.token,
    });
    setState(() {

      //  this.page = Provider.of<WebPageProvider>(context, listen: false).page;
    });

  }
  /* Check if any forms are available
   */
  _loadForms(user) async {

    _formsLoading = true;
    _loadingStates['formcategories'] = LoadingState.loading;


    Map<String, dynamic> params = {
      'displayinapp': 'true',
      'api_key': user?.token,
    };
    dynamic result = await objectmodel.FormCategoryProvider().loadItems(params);

    if (result.length>0) {
      formCategories =result;
    }

    setState(() {
      _loadingStates['formcategories'] = LoadingState.done;

      _formsLoading = false;
    });
  }

  /*
  Check if user has activities with MODIFY or greater access, for displaying 'my activities' link
   */
  _loadMyActivities(user, type) async {
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
      'api_key': user.token ?? '',
      'sort': 'nexteventdate',
    };
    if (type == 'activity') {
      params['startfrom'] = DateFormat('yyyy-MM-dd').format(now);
    }
    try {
    //  print('checking for user own activities of type ' + type);
      var nextActivities = await widget.provider.loadItems(params);
      setState(() {
        //   print(nextActivities.length.toString() + ' items loaded for ' + type);
        _loadingStates[type] = LoadingState.done;
        List<Activity> loadedActivities = [];
        loadedActivities.addAll(nextActivities);
        myActivities[type] = loadedActivities;


        _isLoading = false;
      });
    } catch (e) {
      _isLoading = false;

      errormessage = e.toString();
      if (_loadingStates[type] == LoadingState.loading) {
        setState(() => _loadingStates[type] = LoadingState.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    //AuthProvider auth = Provider.of<AuthProvider>(context);
    User user = Provider.of<UserProvider>(context).user;
    page = Provider.of<WebPageProvider>(context).page;

    imageprovider = objectmodel.ImageProvider();

    bool hasInfoPage =
        page.id != null && page.runtimeType.toString() == 'WebPage'
            ? true
            : false;
    bool isTester = false;

    if (user.data != null) {
      if (user.data!['istester'] != null) {
        if (user.data!['istester'] == 'true') isTester = true;
      }
    }


    ImageProvider backgroundImage = AssetImage("images/splash.png");

    if(page.data!=null) {
      if (page.data!['thumbnailurl'] != null) {
        backgroundImage = NetworkImage(page.data!['thumbnailurl']);
      }

    }

    List<Widget> dashboardButtons = [];

      if (user.token != null) {
        dashboardButtons.add(
        MaterialButton(
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

        ));
      }
      if (user.token != null) {
        dashboardButtons.add(
        dashboardButton(AppLocalizations.of(context)!.qrScanner,
            Icons.qr_code, openQRScanner));
      }
      dashboardButtons.add(
      dashboardButton(AppLocalizations.of(context)!.calendar,
          Icons.calendar_today, openCalendar));
    dashboardButtons.add(dashboardButton(AppLocalizations.of(context)!.discover,
          Icons.search, openActivityList));
    if (myActivities['activity']?.isNotEmpty ?? false) {
      dashboardButtons.add(dashboardButton(AppLocalizations.of(context)!.myActivities,Icons.list_alt_outlined,openMyActivities));
    }

    bool hascontent = myActivities['location'] != null
        ? myActivities['location']!.isNotEmpty
        : false;
    if (hascontent) {
      dashboardButtons.add(dashboardButton(
          AppLocalizations.of(context)!.locations, Icons.house_outlined,
          openLocationsList));
    }
    hascontent = formCategories.isNotEmpty;
    if (hascontent) {
      dashboardButtons.add(dashboardButton(AppLocalizations.of(context)!.forms,
          Icons.list_alt, openForms));
    }

    dashboardButtons.add( dashboardButton(AppLocalizations.of(context)!.settings,
          Icons.settings, openSettingsScreen));
    dashboardButtons.add(dashboardButton(
          user.token == null
              ? AppLocalizations.of(context)!.login
              : AppLocalizations.of(context)!.logout,
          (user.token == null) ? Icons.login : Icons.logout,
          openLoginLink));

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.youthcardDashboard),
        elevation: 0.1,
        actions: [
          if (hasInfoPage)
            IconButton(
                icon: Icon(Icons.info_outline_rounded),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ContentPageView(widget.viewTitle,
                        providedPage: page),
                  ));
                }),
          if (isTester)
            IconButton(
                icon: Icon(Icons.bug_report),
                onPressed: () {
                  feedbackAction(context, user);
                }),
          IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {

                setState(() {
                  _loadingStates.forEach((key, value) {
                    _loadingStates[key] = LoadingState.loading;
                  });
                  _isLoading = false;
                  if (user.token != null) {
                    for (var a in activityTypes) {
                      _loadMyActivities(user, a);
                    }
                  }

                  Provider.of<WebPageProvider>(context, listen: false)
                      .refresh(user);

                    _loadForms(user);
                });
              }),
          if (user.token != null)
            InkWell(
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: user.image != null && user.image!.isNotEmpty
                      ? CachedNetworkImageProvider(user.image!)
                      : null,
                  child: getInitials(user),
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
              image: backgroundImage,
              fit: BoxFit.cover
          ),
        ),
        constraints: BoxConstraints.expand(),
        child: GridView.count(
          // Create a grid with 2 columns. If you change the scrollDirection to
          // horizontal, this produces 2 rows.
          crossAxisCount: dashboardButtons.length>6 ?3 :2,
          crossAxisSpacing: 0,
          mainAxisSpacing: 0,
          padding: EdgeInsets.only(top: 20, left: 20, right: 20,bottom:0),
          children: dashboardButtons,
        ),
      ),
        bottomNavigationBar: bottomNavigation(context),
    );
  }

  void openQRScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QRScanner()),
    );
  }

  void openSettingsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsScreen()),
    );
  }

  void openLoginLink() {
    UserPreferences().removeUser();
    Provider.of<UserProvider>(context, listen: false).clearUser();
    Navigator.pushReplacementNamed(context, '/login');
  }

  void openCalendar() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ActivityCalendar(provider, imageprovider)),
    );
  }

  void openActivityList() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CategorisedActivityList(imageprovider)),
    );
  }
  void openLocationsList()
  {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ActivityList(
              provider, imageprovider,
              viewType: 'locations')),
    );
  }
  void logoutAction() {
    UserPreferences().removeUser();
    Provider.of<UserProvider>(context, listen: false).clearUser();
    Navigator.pushReplacementNamed(context, '/login');
  }
  void openForms()
  {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => FormList()),
    );
  }

  Widget dashboardButton(text, icon, action) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: ClipOval(
        child: Material(
          color: Theme.of(context).primaryColor, // button color
          child: InkWell(
            splashColor: Colors.green, // splash color
            onTap: () => action(), // button pressed
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  icon,
                  size: 40,
                  color: Colors.white,
                ), // icon
                Text(text,
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,) // text
              ],
            ),
          ),
        ),
      ),
    );
  }

  void formsLink(user) {
      if(_loadingStates['formcategories'] == LoadingState.loading) {
        if (!_formsLoading && user.token != null) {
          _loadForms(user);
        }
      }
  }

  void myLocationsListLink(user, userprovider, imageprovider) {
    if(_loadingStates['location']==LoadingState.loading) {
      if (!_isLoading && user.token != null) {
        _loadMyActivities(user, 'location');
      }
    }
  }
  void openMyActivities(){
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ActivityList(
              provider, imageprovider,
              viewType: 'own')),
    );
  }
  void myActivitiesListLink(user, userprovider, imageprovider) {
    if(_loadingStates['activity'] ==LoadingState.loading) {
      if (!_isLoading && user.token != null) {
        _loadMyActivities(user, 'activity');
      }
    }
  }
}
