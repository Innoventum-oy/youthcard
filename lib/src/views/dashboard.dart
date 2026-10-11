import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:youth_card/src/objects/formcategory.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/objects/webpage.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:youth_card/src/providers/web_page_provider.dart';
import 'package:youth_card/src/util/widgets.dart';
import 'package:youth_card/src/util/brand.dart';
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
    try {
      await Provider.of<WebPageProvider>(context,listen:false).loadItem({
      'language': Localizations.localeOf(context).toString(),
      'commonname': widget.viewTitle,
      'fields': 'id,commonname,pagetitle,textcontents,thumbnailurl',
      if (user.token != null) 'api_key': user.token,
      });
      if (mounted) setState(() {});
    } catch (error) {
      if (mounted) setState(() => errormessage = error.toString());
    }
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
    try {
      final result = await objectmodel.FormCategoryProvider().loadItems(params);
      if (!mounted) return;
      setState(() {
        formCategories = result;
        _loadingStates['formcategories'] = LoadingState.done;
        _formsLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        errormessage = error.toString();
        _loadingStates['formcategories'] = LoadingState.error;
        _formsLoading = false;
      });
    }
  }

  /*
  Check if user has activities with MODIFY or greater access, for displaying 'my activities' link
   */
  _loadMyActivities(user, type) async {
    _isLoading = true;
    _loadingStates[type] = LoadingState.loading;
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
      if (!mounted) return;
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
      if (mounted && _loadingStates[type] == LoadingState.loading) {
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


    List<Widget> dashboardButtons = [];

      if (user.token != null) {
        dashboardButtons.add(
          Card(
            color: Theme.of(context).colorScheme.primary,
            margin: const EdgeInsets.only(bottom: 20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyCard()),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const BrandIcon(size: 36),
                      const SizedBox(width: 12),
                      Text('YOUTH CARD', style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.85),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      )),
                    ]),
                    const SizedBox(height: 20),
                    Text(user.fullname.trim().isEmpty
                        ? AppLocalizations.of(context)!.myCard
                        : user.fullname,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    Text('${AppLocalizations.of(context)!.myCard}  →',
                        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
        );
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
                if (user.token != null) {
                  for (final type in activityTypes) {
                    _loadMyActivities(user, type);
                  }
                }
                Provider.of<WebPageProvider>(context, listen: false).refresh(user);
                _loadForms(user);
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          Text(AppLocalizations.of(context)!.youthcardDashboard,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 24),
          ...dashboardButtons,
        ],
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

  Widget dashboardButton(String text, IconData icon, VoidCallback action) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
        title: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w600),
          textAlign: TextAlign.left,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: action,
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
