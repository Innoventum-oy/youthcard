import 'dart:async';

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
import 'package:youth_card/src/util/activity_thumbnail.dart';
import 'package:youth_card/src/util/navigator.dart';
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

String dashboardGreetingForHour(AppLocalizations strings, int hour) {
  if (hour < 12) return strings.dashboardGreeting;
  if (hour < 18) return strings.dashboardAfternoon;
  return strings.dashboardEvening;
}

String? dashboardBackgroundUrl(WebPage page) {
  final candidate = page.data?['thumbnailurl']?.toString().trim();
  final uri = Uri.tryParse(candidate ?? '');
  if (uri == null ||
      (uri.scheme != 'https' && uri.scheme != 'http') ||
      uri.host.isEmpty) {
    return null;
  }
  return uri.toString();
}

class DashBoard extends StatefulWidget {
  final String viewTitle = 'dashboard';
  final objectmodel.ActivityListProvider provider =
      objectmodel.ActivityListProvider();

  DashBoard({super.key});

  @override
  DashBoardState createState() => DashBoardState();
}

class DashBoardState extends State<DashBoard> {
  Timer? _greetingTimer;
  final Map<String, LoadingState> _loadingStates = {};
  Map<String, List<Activity>> myActivities = {};
  List<FormCategory> formCategories = [];
  bool _isLoading = false;
  bool _formsLoading = false;
  Activity? _upcoming;
  String? errormessage;
  List activityTypes = ['activity', 'location'];
  WebPage page = WebPage();
  objectmodel.ImageProvider imageprovider = objectmodel.ImageProvider();
  objectmodel.ActivityListProvider provider =
      objectmodel.ActivityListProvider();

  @override
  void initState() {
    super.initState();
    _scheduleGreetingUpdate();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      initFunction();
    });
  }
  void _scheduleGreetingUpdate() {
    _greetingTimer?.cancel();
    final now = DateTime.now();
    final next = now.hour < 12
        ? DateTime(now.year, now.month, now.day, 12)
        : now.hour < 18
            ? DateTime(now.year, now.month, now.day, 18)
            : DateTime(now.year, now.month, now.day + 1);
    _greetingTimer = Timer(next.difference(now), () {
      if (mounted) setState(() {});
      _scheduleGreetingUpdate();
    });
  }

  @override
  void dispose() {
    _greetingTimer?.cancel();
    super.dispose();
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
    _loadUpcoming(user);
    //See if info page exists for the view
    _loadWebPage(user);

  }

  Future<void> _loadUpcoming(User user, {bool refresh = false}) async {
    final params = <String, String>{
      'view': 'dashboard-upcoming',
      'activitystatus': 'active',
      'activitytype': 'activity',
      'limit': '1',
      'offset': '0',
      'startfrom': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'sort': 'nexteventdate',
      if (user.token != null) 'api_key': user.token!,
      'fields': 'id,name,nexteventdate,startdate,coverpictureurl,description,activityclass',
    };
    try {
      final items = await context.read<objectmodel.ActivityListProvider>()
          .loadItems(params, refresh: refresh);
      if (mounted) setState(() => _upcoming = items.isEmpty ? null : items.first);
    } catch (_) {
      // The dashboard remains usable when activities are unavailable.
    }
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
    final user = context.watch<UserProvider>().user;
    page = context.watch<WebPageProvider>().page;
    final strings = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final signedIn = user.token != null;
    final hasInfoPage = page.id != null && page.runtimeType == WebPage;
    final backgroundUrl = dashboardBackgroundUrl(page);
    final isTester = user.data?['istester'] == 'true';

    final moreActions = <Widget>[
      if (myActivities['activity']?.isNotEmpty ?? false)
        dashboardButton(strings.myActivities, Icons.list_alt_outlined,
            openMyActivities),
      if (myActivities['location']?.isNotEmpty ?? false)
        dashboardButton(strings.locations, Icons.place_outlined,
            openLocationsList),
      if (formCategories.isNotEmpty)
        dashboardButton(strings.forms, Icons.description_outlined, openForms),
      dashboardButton(strings.settings, Icons.settings_outlined,
          openSettingsScreen),
      dashboardButton(signedIn ? strings.logout : strings.login,
          signedIn ? Icons.logout : Icons.login, openLoginLink),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const SizedBox.shrink(),
        toolbarHeight: 48,
        actions: [
          if (hasInfoPage)
            IconButton(
              icon: const Icon(Icons.info_outline_rounded),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ContentPageView(widget.viewTitle,
                    providedPage: page),
              )),
            ),
          if (isTester)
            IconButton(
              icon: const Icon(Icons.bug_report),
              onPressed: () => feedbackAction(context, user),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (signedIn) {
                for (final type in activityTypes) {
                  _loadMyActivities(user, type);
                }
              }
              context.read<WebPageProvider>().refresh(user);
              _loadForms(user);
              _loadUpcoming(user, refresh: true);
            },
          ),
          if (signedIn)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => MyCard())),
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: user.image != null && user.image!.isNotEmpty
                      ? CachedNetworkImageProvider(user.image!)
                      : null,
                  child: getInitials(user),
                ),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        children: [
          if (backgroundUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: SizedBox(
                height: 168,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: backgroundUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, _) =>
                          ColoredBox(color: colors.primaryContainer),
                      errorWidget: (_, _, _) =>
                          ColoredBox(color: colors.primaryContainer),
                    ),
                    DecoratedBox(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x99000000), Color(0xCC000000)],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dashboardGreetingForHour(
                                strings,
                                DateTime.now().hour,
                              ),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              strings.yourYouthCard,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            Text(
              dashboardGreetingForHour(strings, DateTime.now().hour),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              strings.yourYouthCard,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          const SizedBox(height: 20),
          if (signedIn) ...[
            Card(
              margin: EdgeInsets.zero,
              color: colors.primary,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => MyCard())),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(child: Text('YOUTH CARD',
                            style: theme.textTheme.labelMedium?.copyWith(
                                color: colors.onPrimary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1))),
                        const BrandIcon(size: 46),
                      ]),
                      const SizedBox(height: 6),
                      Text(user.fullname.trim().isEmpty
                              ? strings.myCard : user.fullname,
                          style: theme.textTheme.headlineSmall?.copyWith(
                              color: colors.onPrimary,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      if (user.id != null)
                        Text('${strings.memberId}  •  ${user.id}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: colors.onPrimary)),
                      const SizedBox(height: 12),
                      Text('${strings.myCard}  →',
                          style: theme.textTheme.titleMedium?.copyWith(
                              color: colors.onPrimary,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          Text(strings.quickAccess,
              style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _shortcut(Icons.qr_code_scanner,
                strings.qrScanner, signedIn ? openQRScanner : openLoginLink)),
            const SizedBox(width: 10),
            Expanded(child: _shortcut(Icons.search,
                strings.discover, openActivityList)),
            const SizedBox(width: 10),
            Expanded(child: _shortcut(Icons.calendar_month_outlined,
                strings.calendar, openCalendar)),
          ]),
          const SizedBox(height: 24),
          if (_upcoming != null) ...[
            Card(
              margin: EdgeInsets.zero,
              color: theme.brightness == Brightness.dark
                  ? const Color(0xFF703B3A)
                  : const Color(0xFFFFE4DE),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => goToActivity(context, _upcoming!),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    ActivityThumbnail(eventUrl: _upcoming!.coverpictureurl,
                        categoryId: _upcoming!.activityClassId,
                        width: 76, height: 76,
                        borderRadius: BorderRadius.circular(12)),
                    const SizedBox(width: 14),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(strings.comingUp.toUpperCase(),
                            style: theme.textTheme.labelMedium?.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(_upcoming!.name ?? strings.unnamedActivity,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold)),
                        if (_upcoming!.nexteventdate != null) ...[
                          const SizedBox(height: 6),
                          Text(DateFormat('d MMM • HH:mm',
                                  Localizations.localeOf(context).toString())
                              .format(_upcoming!.nexteventdate!),
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant)),
                        ],
                      ],
                    )),
                  ]),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          ...moreActions,
        ],
      ),
      bottomNavigationBar: bottomNavigation(context),
    );
  }

  Widget _shortcut(IconData icon, String label, VoidCallback onTap) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 27),
              const SizedBox(height: 8),
              Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
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
          builder: (context) => const ActivityCalendar()),
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
