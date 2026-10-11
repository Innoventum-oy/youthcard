import 'package:flutter/material.dart';
import 'package:youth_card/src/objects/activityclass.dart';
import 'package:youth_card/l10n/app_localizations.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/util/utils.dart';
import 'package:youth_card/src/util/widgets.dart';
import 'package:youth_card/src/views/activity/activitylistsliver.dart';
import 'package:youth_card/src/util/activity_thumbnail.dart';
import 'package:provider/provider.dart';
import 'package:youth_card/src/providers/index.dart' as object_model;

class CategorisedActivityList extends StatefulWidget {
  final object_model.ImageProvider imageProvider;
  final String viewType;

  const CategorisedActivityList(
    this.imageProvider, {
    super.key,
    this.viewType = 'all',
  });

  @override
  CategorisedActivityListState createState() => CategorisedActivityListState();
}

class CategorisedActivityListState extends State<CategorisedActivityList> {
  Map<String, dynamic>? map;
  List<ActivityClass> data = [];
  User? user;
  LoadingState _loadingState = LoadingState.loading;
  bool _isLoading = false;
  bool _hasMore = true;
  int iteration = 1;
  int buildtime = 1;
  int limit = 20;
  int _pageNumber = 0;
  String? errormessage;

  notify(String text) {
    final snackBar = SnackBar(content: Text(text));

    // Find the ScaffoldMessenger in the widget tree
    // and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  _loadNextPage(user, {bool refresh = false}) async {
    if (_isLoading || !_hasMore) return;
    _isLoading = true;
    int offset = limit * _pageNumber;

    final Map<String, String> params = {
      'loadmethod': 'loadActivityClassesWithActivities',
      'limit': limit.toString(),
      'offset': offset.toString(),
      if (user.token != null) 'api_key': user.token,

      'sort': 'name',
    };

    object_model.ActivityClassProvider activityClassProvider =
        object_model.ActivityClassProvider();

    try {
      var activityCategories = await activityClassProvider.loadItems(
        params,
        refresh: refresh,
      );
      if (!mounted) return;
      setState(() {
        _loadingState = LoadingState.done;
        data.addAll(activityCategories);
        _hasMore = activityCategories.length >= limit;
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
      User user = Provider.of<object_model.UserProvider>(
        context,
        listen: false,
      ).user;
      _loadNextPage(user);
    });
    super.initState();
  }

  @override
  @protected
  @mustCallSuper
  void dispose() {
    _loadingState = LoadingState.loading;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<object_model.UserProvider>(
      context,
      listen: false,
    ).user;

    bool isTester = false;
    if (user.data != null) {
      if (user.data!['istester'] != null) {
        if (user.data!['istester'] == 'true') isTester = true;
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const SizedBox.shrink(),
        toolbarHeight: 48,
        actions: [
          if (isTester)
            IconButton(
              icon: Icon(Icons.bug_report),
              onPressed: () {
                feedbackAction(context, user);
              },
            ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                data = [];
                _pageNumber = 0;
                _loadingState = LoadingState.loading;
                _isLoading = false;
                _hasMore = true;
              });
              _loadNextPage(user, refresh: true);
            },
          ),
        ],
      ),
      body: _getContentSection(user),
      bottomNavigationBar: bottomNavigation(context, currentIndex: 1),
    );
  }

  Widget _getContentSection(user) {
    switch (_loadingState) {
      case LoadingState.done:
        //data loaded
        return data.isEmpty
            ? Container(
                padding: EdgeInsets.all(20),
                child: ListTile(
                  leading: const Icon(Icons.event_busy_outlined),
                  title: Text(AppLocalizations.of(context)!.noActivitiesFound),
                ),
              )
            : CustomScrollView(
                slivers: <Widget>[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.discover,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            AppLocalizations.of(context)!.findNearby,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      if (!_isLoading &&
                          _hasMore &&
                          index > (data.length * 0.7)) {
                        _loadNextPage(user);
                      }
                      if (data.isNotEmpty) {
                        return activityClassView(data[index]);
                      } else {
                        return Container();
                      }
                    }, childCount: data.length),
                  ),
                ],
              );
      case LoadingState.error:
        //data loading returned error state
        return Align(
          alignment: Alignment.center,
          child: ListTile(
            leading: Icon(Icons.error),
            title: Text(
              'Sorry, there was an error loading the activity classes : $errormessage',
            ),
          ),
        );

      case LoadingState.loading:
        //data loading in progress
        //  if(!_isLoading) _loadNextPage(user);
        return Align(
          alignment: Alignment.center,
          child: Center(
            child: ListTile(
              leading: CircularProgressIndicator(),
              title: Text(
                AppLocalizations.of(context)!.loading,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        );
      default:
        return Container();
    }
  }

  Widget activityClassView(activityClass) {
    final activityProvider = context.read<object_model.ActivityListProvider>();
    return Card(
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 12),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ActivityThumbnail(
                  categoryUrl: activityClass.coverpictureurl,
                  width: 88,
                  height: 72,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    activityClass.name ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ActivityListSliver(
              activityProvider,
              widget.imageProvider,
              activityClass,
            ),
          ],
        ),
      ),
    );
  }
}
