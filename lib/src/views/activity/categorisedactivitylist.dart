import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:youth_card/l10n/app_localizations.dart';
import 'package:youth_card/src/objects/activity.dart';
import 'package:youth_card/src/providers/activity_list_provider.dart';
import 'package:youth_card/src/providers/image_provider.dart' as app_images;
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/util/activity_thumbnail.dart';
import 'package:youth_card/src/util/navigator.dart';
import 'package:youth_card/src/util/utils.dart';
import 'package:youth_card/src/util/widgets.dart';
import 'package:youth_card/src/views/activity/activity_category_browser.dart';

enum _DiscoverFilter { all, activities, places }

class _FeedPage {
  final items = <Activity>[];
  int offset = 0;
  bool hasMore = true;
  bool loading = false;
  String? error;
}

class _FeedItem {
  const _FeedItem(this.activity, this.isPlace);

  final Activity activity;
  final bool isPlace;
}

/// The Discover landing view; categories are a secondary browse route.
class CategorisedActivityList extends StatefulWidget {
  const CategorisedActivityList(
    this.imageProvider, {
    super.key,
    this.viewType = 'all',
  });

  final app_images.ImageProvider imageProvider;
  final String viewType;

  @override
  State<CategorisedActivityList> createState() => _DiscoverFeedState();
}

class _DiscoverFeedState extends State<CategorisedActivityList> {
  static const _pageSize = 20;
  final _scrollController = ScrollController();
  final _activities = _FeedPage();
  final _places = _FeedPage();
  _DiscoverFilter _filter = _DiscoverFilter.all;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadVisible());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 360) _loadVisible();
  }

  Future<void> _loadVisible({bool refresh = false}) async {
    final requests = switch (_filter) {
      _DiscoverFilter.all => [
        _loadPage(_activities, 'activity', refresh: refresh),
        _loadPage(_places, 'location', refresh: refresh),
      ],
      _DiscoverFilter.activities => [
        _loadPage(_activities, 'activity', refresh: refresh),
      ],
      _DiscoverFilter.places => [
        _loadPage(_places, 'location', refresh: refresh),
      ],
    };
    await Future.wait(requests);
  }

  Future<void> _loadPage(
    _FeedPage page,
    String type, {
    bool refresh = false,
  }) async {
    if (page.loading || (!refresh && !page.hasMore)) return;
    setState(() {
      page.loading = true;
      page.error = null;
    });
    final user = context.read<UserProvider>().user;
    final offset = refresh ? 0 : page.offset;
    final params = <String, String>{
      'view': 'discover-feed',
      'activitystatus': 'active',
      'activitytype': type,
      'grouping': 'activity.id',
      'limit': '$_pageSize',
      'offset': '$offset',
      'sort': type == 'location' ? 'name' : 'nexteventdate',
      if (type == 'activity')
        'startfrom': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      if (user.token != null) 'api_key': user.token!,
      'fields': 'id,name,nexteventdate,startdate,coverpictureurl,city',
    };
    try {
      final next = await context.read<ActivityListProvider>().loadItems(
        params,
        refresh: refresh,
      );
      if (!mounted) return;
      setState(() {
        if (refresh) {
          page.items.clear();
          page.offset = 0;
        }
        final seen = page.items.map((item) => item.id).toSet();
        var added = 0;
        for (final item in next) {
          if (seen.add(item.id)) {
            page.items.add(item);
            added++;
          }
        }
        page.offset += next.length;
        page.hasMore = next.length == _pageSize && added > 0;
        page.loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        page.error = error.toString();
        page.loading = false;
      });
    }
  }

  void _select(_DiscoverFilter filter) {
    setState(() => _filter = filter);
    if ((filter == _DiscoverFilter.all ||
            filter == _DiscoverFilter.activities) &&
        _activities.offset == 0 &&
        _activities.hasMore) {
      _loadPage(_activities, 'activity');
    }
    if ((filter == _DiscoverFilter.all || filter == _DiscoverFilter.places) &&
        _places.offset == 0 &&
        _places.hasMore) {
      _loadPage(_places, 'location');
    }
  }

  List<_FeedItem> get _items {
    final activities = [
      for (final activity in _activities.items) _FeedItem(activity, false),
    ];
    final places = [
      for (final activity in _places.items) _FeedItem(activity, true),
    ];
    final combined = switch (_filter) {
      _DiscoverFilter.activities => activities,
      _DiscoverFilter.places => places,
      _DiscoverFilter.all => _interleave(activities, places),
    };
    if (_query.isEmpty) return combined;
    final query = _query.toLowerCase();
    return combined.where((entry) {
      final activity = entry.activity;
      return (activity.name?.toLowerCase().contains(query) ?? false) ||
          (activity.city?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  List<_FeedItem> _interleave(
    List<_FeedItem> activities,
    List<_FeedItem> places,
  ) {
    final result = <_FeedItem>[];
    var activityIndex = 0;
    var placeIndex = 0;
    while (activityIndex < activities.length || placeIndex < places.length) {
      for (
        var index = 0;
        index < 2 && activityIndex < activities.length;
        index++
      ) {
        result.add(activities[activityIndex++]);
      }
      if (placeIndex < places.length) result.add(places[placeIndex++]);
    }
    return result;
  }

  bool get _loadingVisible => switch (_filter) {
    _DiscoverFilter.all => _activities.loading || _places.loading,
    _DiscoverFilter.activities => _activities.loading,
    _DiscoverFilter.places => _places.loading,
  };

  bool get _hasMoreVisible => switch (_filter) {
    _DiscoverFilter.all => _activities.hasMore || _places.hasMore,
    _DiscoverFilter.activities => _activities.hasMore,
    _DiscoverFilter.places => _places.hasMore,
  };

  bool get _errorVisible => switch (_filter) {
    _DiscoverFilter.all => _activities.error != null || _places.error != null,
    _DiscoverFilter.activities => _activities.error != null,
    _DiscoverFilter.places => _places.error != null,
  };

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final items = _items;
    final user = context.read<UserProvider>().user;
    final isTester = user.data?['istester'] == 'true';
    return Scaffold(
      appBar: AppBar(
        title: Text(
          strings.discover,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        titleSpacing: 24,
        actions: [
          if (isTester)
            IconButton(
              icon: const Icon(Icons.bug_report_outlined),
              onPressed: () => feedbackAction(context, user),
            ),
          IconButton(
            tooltip: strings.refresh,
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadVisible(refresh: true),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadVisible(refresh: true),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _header(strings, theme, colors)),
            if (_errorVisible)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text(strings.networkError),
                    ),
                  ),
                ),
              ),
            if (items.isEmpty && _loadingVisible)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else if (items.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(strings.noDiscoverResults),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) => _card(items[index], strings),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
                child: items.isEmpty && _loadingVisible
                    ? const SizedBox.shrink()
                    : _loadingVisible
                    ? const Center(child: CircularProgressIndicator())
                    : _hasMoreVisible
                    ? Center(
                        child: TextButton(
                          onPressed: _loadVisible,
                          child: Text(strings.loadMore),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: bottomNavigation(context, currentIndex: 1),
    );
  }

  Widget _header(
    AppLocalizations strings,
    ThemeData theme,
    ColorScheme colors,
  ) {
    final cardColor = theme.cardTheme.color ?? colors.surface;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.findNearby,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 46,
            child: TextField(
              onChanged: (value) => setState(() => _query = value.trim()),
              decoration: InputDecoration(
                hintText: strings.searchDiscover,
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: cardColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          if (_query.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                strings.searchLoadedHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          const SizedBox(height: 20),
          Row(
            children: [
              _filterButton(strings.all, _DiscoverFilter.all, colors),
              const SizedBox(width: 7),
              _filterButton(
                strings.activities,
                _DiscoverFilter.activities,
                colors,
              ),
              const SizedBox(width: 7),
              _filterButton(strings.places, _DiscoverFilter.places, colors),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  strings.featuredForYou,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        ActivityCategoryBrowser(widget.imageProvider),
                  ),
                ),
                child: Text(strings.browseCategories),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterButton(
    String label,
    _DiscoverFilter filter,
    ColorScheme colors,
  ) {
    final selected = _filter == filter;
    return Expanded(
      child: InkWell(
        key: ValueKey('discover-filter-${filter.name}'),
        onTap: () => _select(filter),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 9),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: selected ? colors.primary : colors.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: selected ? colors.onPrimary : colors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _card(_FeedItem item, AppLocalizations strings) {
    final activity = item.activity;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final date = activity.nexteventdate ?? activity.startdate;
    final locale = Localizations.localeOf(context).toString();
    final subtitle = item.isPlace
        ? [
            strings.places,
            if (activity.city?.isNotEmpty == true) activity.city!,
          ].join(' · ')
        : [
            strings.activity,
            if (date != null) DateFormat('d MMM', locale).format(date),
          ].join(' · ');
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => goToActivity(context, activity),
        child: SizedBox(
          height: 96,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ActivityThumbnail(
                  eventUrl: activity.coverpictureurl,
                  width: 72,
                  height: 72,
                  borderRadius: BorderRadius.circular(12),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.name ?? strings.unnamedActivity,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
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
