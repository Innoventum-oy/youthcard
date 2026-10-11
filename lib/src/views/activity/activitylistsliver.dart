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
import 'package:youth_card/src/util/activity_thumbnail.dart';

class ActivityListSliver extends StatefulWidget {
  final object_model.ActivityListProvider activityProvider;
  final object_model.ImageProvider imageProvider;
  final ActivityClass activityClass;

  const ActivityListSliver(
    this.activityProvider,
    this.imageProvider,
    this.activityClass, {
    super.key,
  });

  @override
  ActivityListSliverState createState() => ActivityListSliverState();
}

class ActivityListSliverState extends State<ActivityListSliver> {
  Map<String, dynamic>? map;
  List<Activity> data = [];
  User? user;
  LoadingState _loadingState = LoadingState.loading;
  bool _isLoading = false;
  bool _hasMore = true;
  int iteration = 1;
  int buildtime = 1;
  int limit = 20;
  int count = 0;
  int _pageNumber = 0;
  String? errormessage;

  notify(String text) {
    final snackBar = SnackBar(content: Text(text));

    // Find the ScaffoldMessenger in the widget tree
    // and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  int calculateDifference(DateTime date) {
    DateTime now = DateTime.now();
    return DateTime(
      date.year,
      date.month,
      date.day,
    ).difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  _loadNextPage(user, activityclass) async {
    if (_isLoading || !_hasMore) return;
    _isLoading = true;
    int offset = limit * _pageNumber;
    DateTime now = DateTime.now();
    final Map<String, String> params = {
      'view': 'activitylistsliver',
      'activityclass': 'id:${activityclass.id}',
      'activitystatus': 'active',
      'activitytype': 'activity',
      'grouping': 'activity.id',
      'limit': limit.toString(),
      'offset': offset.toString(),
      'startfrom': DateFormat('yyyy-MM-dd').format(now),
      if (user.token != null) 'api_key': user.token,

      'sort': 'nexteventdate',
    };

    try {
      var nextActivities = await widget.activityProvider.loadItems(params);
      if (!mounted) return;
      setState(() {
        _loadingState = LoadingState.done;
        data.addAll(nextActivities);
        _hasMore = nextActivities.length >= limit;
        _isLoading = false;
        _pageNumber++;
      });
    } catch (e) {
      if (!mounted) return;
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
        if (data.isEmpty) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(2, 12, 2, 4),
            child: Row(
              children: [
                Icon(
                  Icons.event_busy_outlined,
                  size: 18,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Text(
                  AppLocalizations.of(context)!.noActivitiesFound,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }
        return SizedBox(
          height: 260,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            scrollDirection: Axis.horizontal,
            itemCount: data.length,
            itemBuilder: (BuildContext context, int index) {
              if (!_isLoading && _hasMore && index > (data.length * 0.7)) {
                _loadNextPage(user, widget.activityClass);
              }

              return activityHorizontal(data[index]);
            },
          ),
        );

      case LoadingState.error:
        //data loading returned error state
        return Padding(
          padding: const EdgeInsets.fromLTRB(2, 12, 2, 4),
          child: ListTile(
            leading: Icon(Icons.error),
            title: Text(
              'Sorry, there was an error loading the data: $errormessage',
            ),
          ),
        );

      case LoadingState.loading:
        //data loading in progress
        return SizedBox(
          height: 56,
          child: Center(
            child: ListTile(
              leading: CircularProgressIndicator(),
              title: Text(
                AppLocalizations.of(context)!.loading,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
        );
      default:
        return Text('No activities found in this category');
    }
  }

  Widget activityHorizontal(activity) {
    String dateinfo = activity.nexteventdate == null
        ? ''
        : (calculateDifference(activity.nexteventdate!) != 0
              ? DateFormat('kk:mm dd.MM.yyyy').format(activity.nexteventdate!)
              : AppLocalizations.of(context)!.today +
                    DateFormat('kk:mm ').format(activity.startdate!));

    return SizedBox(
      width: 184,
      child: Card(
        margin: const EdgeInsets.only(right: 12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => goToActivity(context, activity),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ActivityThumbnail(
                  eventUrl: activity.coverpictureurl,
                  categoryUrl: widget.activityClass.coverpictureurl,
                  categoryId: activity.activityClassId,
                  categoryImageId: widget.activityClass.coverpicture,
                  width: double.infinity,
                  height: 116,
                ),
                const SizedBox(height: 10),
                Text(
                  activity.name ??
                      AppLocalizations.of(context)!.unnamedActivity,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  dateinfo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
