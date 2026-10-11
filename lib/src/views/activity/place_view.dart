import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:youth_card/l10n/app_localizations.dart';
import 'package:youth_card/src/objects/activity.dart';
import 'package:youth_card/src/providers/activity_list_provider.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/util/activity_thumbnail.dart';
import 'package:youth_card/src/util/navigator.dart';
import 'package:youth_card/src/util/place_activity_matcher.dart';
import 'package:provider/provider.dart';

/// A location and its upcoming activities, filtered by the iCMS address field.
class PlaceView extends StatefulWidget {
  const PlaceView(this.place, this.provider, {super.key, this.previewActivity});

  final Activity place;
  final ActivityListProvider provider;
  final Activity? previewActivity;

  @override
  State<PlaceView> createState() => _PlaceViewState();
}

class _PlaceViewState extends State<PlaceView> {
  static const _pageSize = 20;
  final _items = <Activity>[];
  int _offset = 0;
  bool _hasMore = true;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPage());
  }

  Future<void> _loadPage({bool refresh = false}) async {
    if (_loading || (!refresh && !_hasMore)) return;
    final address = widget.place.address?.trim();
    if (address == null || address.isEmpty) {
      setState(() => _hasMore = false);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final token = context.read<UserProvider>().user.token;
    final params = <String, String>{
      'view': 'place-upcoming',
      'activitystatus': 'active',
      'activitytype': 'activity',
      'address': address,
      'grouping': 'activity.id',
      'limit': '$_pageSize',
      'offset': '${refresh ? 0 : _offset}',
      'startfrom': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'sort': 'nexteventdate',
      'fields':
          'id,name,address,city,nexteventdate,startdate,coverpictureurl,activityclass,activitytype',
    };
    if (token != null) params['api_key'] = token;
    try {
      final next = await widget.provider.loadItems(params, refresh: refresh);
      if (!mounted) return;
      setState(() {
        if (refresh) {
          _items.clear();
          _offset = 0;
        }
        final seen = _items.map((item) => item.id).toSet();
        var added = 0;
        for (final item in next) {
          if (PlaceActivityMatcher.matches(widget.place, item) &&
              seen.add(item.id)) {
            _items.add(item);
            added++;
          }
        }
        _offset += next.length;
        _hasMore = next.length == _pageSize && added > 0;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final imageActivity =
        widget.previewActivity ?? (_items.isNotEmpty ? _items.first : null);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.place.name ?? strings.places),
        actions: [
          IconButton(
            tooltip: strings.refresh,
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : () => _loadPage(refresh: true),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadPage(refresh: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          children: [
            ActivityThumbnail(
              eventUrl:
                  widget.place.coverpictureurl ??
                  imageActivity?.coverpictureurl,
              categoryId: widget.place.coverpictureurl == null
                  ? imageActivity?.activityClassId
                  : null,
              width: double.infinity,
              height: 180,
              borderRadius: BorderRadius.circular(20),
            ),
            const SizedBox(height: 20),
            Text(
              widget.place.name ?? strings.places,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.place.address?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(
                [
                  widget.place.address!.trim(),
                  if (widget.place.city?.trim().isNotEmpty == true)
                    widget.place.city!.trim(),
                ].join(' · '),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 28),
            Text(
              strings.comingUp,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(strings.networkError),
                  ),
                ),
              ),
            if (_items.isEmpty && _loading)
              const Padding(
                padding: EdgeInsets.all(28),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_items.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(strings.noUpcomingActivities),
                ),
              ),
            for (final activity in _items)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => goToActivity(context, activity),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          ActivityThumbnail(
                            eventUrl: activity.coverpictureurl,
                            categoryId: activity.activityClassId,
                            width: 72,
                            height: 72,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activity.name ?? strings.unnamedActivity,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (activity.nexteventdate ?? activity.startdate
                                    case final DateTime date) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    DateFormat(
                                      'd MMM · HH:mm',
                                      locale,
                                    ).format(date),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (_items.isNotEmpty && _loading)
              const Center(child: CircularProgressIndicator()),
            if (!_loading && _hasMore)
              Center(
                child: TextButton(
                  onPressed: _loadPage,
                  child: Text(strings.loadMore),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
