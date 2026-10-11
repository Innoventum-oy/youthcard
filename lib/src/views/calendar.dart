import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:youth_card/l10n/app_localizations.dart';
import 'package:youth_card/src/objects/activity.dart';
import 'package:youth_card/src/providers/activity_list_provider.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/util/activity_thumbnail.dart';
import 'package:youth_card/src/util/navigator.dart';
import 'package:youth_card/src/util/widgets.dart';

class ActivityCalendar extends StatefulWidget {
  const ActivityCalendar({super.key});

  @override
  State<ActivityCalendar> createState() => _ActivityCalendarState();
}

class _ActivityCalendarState extends State<ActivityCalendar> {
  late final DateTime _firstDay;
  late final DateTime _lastDay;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<int, List<Activity>> _events = {};
  List<Activity> _activities = [];
  int _visibleLimit = 20;
  bool _loading = true;
  bool _fetching = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _firstDay = DateTime(now.year, now.month - 1);
    _lastDay = DateTime(now.year, now.month + 4, 0);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadEvents());
  }

  int _dayKey(DateTime date) => date.year * 10000 + date.month * 100 + date.day;

  List<Activity> _eventsForDay(DateTime day) => _events[_dayKey(day)] ?? [];

  Future<void> _loadEvents({bool refresh = false}) async {
    if (_fetching) return;
    _fetching = true;
    final user = context.read<UserProvider>().user;
    final params = <String, String>{
      'view': 'calendar',
      'activitystatus': 'active',
      'activitytype': 'activity',
      'limit': '250',
      'sort': 'nexteventdate',
      'startfrom': DateFormat('yyyy-MM-dd').format(_firstDay),
      if (user.token != null) 'api_key': user.token!,
      'fields': 'id,nexteventdate,name,coverpictureurl,startdate',
    };
    final activities = <Activity>[];
    final events = <int, List<Activity>>{};
    try {
      for (var page = 0; page < 8; page++) {
        final pageParams = {...params, 'offset': '${page * 250}'};
        final next = await context.read<ActivityListProvider>().loadItems(
          pageParams,
          refresh: refresh,
        );
        if (!mounted) return;
        activities.addAll(next);
        for (final activity in next) {
          final date = activity.nexteventdate ?? activity.startdate;
          if (date != null) {
            events.putIfAbsent(_dayKey(date), () => []).add(activity);
          }
        }
        setState(() {
          _activities = List.of(activities);
          _events
            ..clear()
            ..addAll(events);
          _error = null;
          _loading = false;
        });
        final lastDate = next.isEmpty
            ? null
            : next.last.nexteventdate ?? next.last.startdate;
        if (next.length < 250 ||
            (lastDate != null && lastDate.isAfter(_lastDay))) {
          break;
        }
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _fetching = false;
        });
      }
    }
  }

  List<Activity> get _visibleActivities {
    if (_selectedDay != null) return _eventsForDay(_selectedDay!);
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final upcoming = _activities.where((activity) {
      final date = activity.nexteventdate ?? activity.startdate;
      return date != null && !date.isBefore(start);
    }).toList();
    upcoming.sort(
      (a, b) => (a.nexteventdate ?? a.startdate!).compareTo(
        b.nexteventdate ?? b.startdate!,
      ),
    );
    return upcoming;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final visible = _visibleActivities;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 24,
        title: Text(
          strings.calendar,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _fetching ? null : () => _loadEvents(refresh: true),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: colors.primary))
          : _error != null && _activities.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(strings.networkError),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => _loadEvents(refresh: true),
                      child: const Icon(Icons.refresh),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: () => _loadEvents(refresh: true),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          DateFormat.yMMMM(locale).format(_focusedDay),
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed:
                            _focusedDay.year == _firstDay.year &&
                                _focusedDay.month == _firstDay.month
                            ? null
                            : () => setState(
                                () => _focusedDay = DateTime(
                                  _focusedDay.year,
                                  _focusedDay.month - 1,
                                ),
                              ),
                        icon: const Icon(Icons.chevron_left),
                      ),
                      IconButton(
                        onPressed:
                            _focusedDay.year == _lastDay.year &&
                                _focusedDay.month == _lastDay.month
                            ? null
                            : () => setState(
                                () => _focusedDay = DateTime(
                                  _focusedDay.year,
                                  _focusedDay.month + 1,
                                ),
                              ),
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Card(
                    margin: EdgeInsets.zero,
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: TableCalendar<Activity>(
                        key: ValueKey(
                          _focusedDay.year * 12 + _focusedDay.month,
                        ),
                        locale: locale,
                        firstDay: _firstDay,
                        lastDay: _lastDay,
                        focusedDay: _focusedDay,
                        startingDayOfWeek: StartingDayOfWeek.monday,
                        calendarFormat: CalendarFormat.month,
                        availableCalendarFormats: const {
                          CalendarFormat.month: 'Month',
                        },
                        headerVisible: false,
                        rowHeight: 40,
                        daysOfWeekHeight: 28,
                        eventLoader: _eventsForDay,
                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDay, day),
                        onDaySelected: (selected, focused) => setState(() {
                          _selectedDay = selected;
                          _focusedDay = focused;
                        }),
                        onPageChanged: (focused) =>
                            setState(() => _focusedDay = focused),
                        calendarStyle: CalendarStyle(
                          outsideDaysVisible: false,
                          todayDecoration: BoxDecoration(
                            color: colors.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          todayTextStyle: TextStyle(
                            color: colors.onPrimaryContainer,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                          ),
                          selectedTextStyle: TextStyle(color: colors.onPrimary),
                          markerDecoration: BoxDecoration(
                            color: colors.tertiary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_fetching) ...[
                    const SizedBox(height: 8),
                    const LinearProgressIndicator(),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          strings.comingUp,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (_selectedDay != null)
                        TextButton(
                          onPressed: () => setState(() => _selectedDay = null),
                          child: Text(strings.all),
                        ),
                    ],
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
                  if (visible.isEmpty)
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(strings.noUpcomingActivities),
                      ),
                    ),
                  for (final activity in visible.take(_visibleLimit))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        margin: EdgeInsets.zero,
                        color: colors.primaryContainer,
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => goToActivity(context, activity),
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
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateFormat(
                                          'd MMM • HH:mm',
                                          locale,
                                        ).format(
                                          activity.nexteventdate ??
                                              activity.startdate ??
                                              DateTime.now(),
                                        ),
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                              color: colors.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        activity.name ??
                                            strings.unnamedActivity,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              color: colors.onPrimaryContainer,
                                              fontWeight: FontWeight.bold,
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
                    ),
                  if (visible.length > _visibleLimit)
                    TextButton(
                      onPressed: () => setState(() => _visibleLimit += 20),
                      child: Text(strings.readMore),
                    ),
                ],
              ),
            ),
      bottomNavigationBar: bottomNavigation(context, currentIndex: 2),
    );
  }
}
