import 'dart:collection';

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:youth_card/src/objects/activity.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:youth_card/src/providers/objectprovider.dart' as objectmodel;
import 'package:http/http.dart' as http;
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/util/utils.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:youth_card/src/views/activity/activitylist_item.dart';



class ActivityCalendar extends StatefulWidget {

  final objectmodel.ActivityProvider provider;
  final objectmodel.ImageProvider imageprovider;

  ActivityCalendar(this.provider,this.imageprovider);

  @override
  _ActivityCalendarState createState() => _ActivityCalendarState();
}

class _ActivityCalendarState extends State<ActivityCalendar> with TickerProviderStateMixin {

  List<Activity> data = [];
  Map<DateTime, List<Activity>> _events = {};

  ValueNotifier<List<Activity>> _selectedEvents = ValueNotifier([]);

  Map<DateTime, List<Activity>> eventsHashMap = <DateTime, List<Activity>>{};
  CalendarFormat _calendarFormat = CalendarFormat.month;

  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOff; // Can be toggled on/off by longpressing a date
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? kFirstDay;
  DateTime? kLastDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  LoadingState _loadingState = LoadingState.LOADING;
  bool _isLoading = false;

  int iteration = 1;
  int buildtime = 1;
  Map<String, dynamic>? map;
  int limit = 1000;
  int _pageNumber = 0;
  String? errormessage;

  _loadCalendarEvents(user) async {
    _isLoading = true;
    int offset = limit * _pageNumber;
    DateTime now = DateTime.now();

    Map<String, String> params = {
      'activitystatus': 'active',
      'activitytype': 'activity',
      'limit': limit.toString(),
      'offset': offset.toString(),
      'startfrom': DateFormat('yyyy-MM-dd').format(kFirstDay ?? now),
      'api-key': user.token,
      'api_key': user.token,
      'fields': 'id, nexteventdate,  name, description'

      //  'fields': ['id','startdate','enddate','']
     // 'sort': 'nexteventdate',
    };
    print('Loading page $_pageNumber');
    try {
      var nextActivities =
      await widget.provider.loadItems(params);
      setState(() {
        _loadingState = LoadingState.DONE;
        print('loadingstate set to DONE after loading ' + nextActivities.length.toString()+ ' items');
        data.addAll(nextActivities);

        for (var item in data) {
          if(item.nexteventdate!=null) {
            if (_events[item.nexteventdate] == null) {
              _events[item.nexteventdate??now] = [];
            }
            _events[item.nexteventdate]!.add(item);
         //   print('populating date ' + item.nexteventdate.toString());
          }
        };

        //print('Adding all '+ _events.length.toString() +' events to eventsHashMap');
        eventsHashMap =
        LinkedHashMap<DateTime, List<Activity>>(equals: isSameDay,
          hashCode: getHashCode,
        )
          ..addAll(_events);
        _onDaySelected(_focusedDay, _focusedDay);
        _getEventsForDay(_selectedDay ?? now);
        _isLoading = false;
        _pageNumber++;
      });
    } catch (e, stack) {
      _isLoading = false;
      //print('loadItems returned error $e\n Stack trace:\n $stack');
      errormessage = e.toString();
      if (_loadingState == LoadingState.LOADING) {
        setState(() => _loadingState = LoadingState.ERROR);
      }
    }
  }

  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    //print('_OnDaySelected was called');
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        //print('is not same day: '+selectedDay.toString());
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
        _selectedEvents.value = _getEventsForDay(selectedDay);
        //print(_selectedEvents);
      });


    }
   // else print('was same day');
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      User user = Provider
          .of<UserProvider>(context, listen: false)
          .user;
      //print('writing selectedevents');
      //_selectedDay = _focusedDay;
      _loadCalendarEvents(user);
      _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay?? DateTime.now()));

    });
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Activity> _getEventsForDay(DateTime day) {

    if(eventsHashMap[day]!=null)print('events for $day: '+ eventsHashMap[day]!.length.toString());
    return eventsHashMap[day] ?? [];
  }


  @override
  Widget build(BuildContext context) {
    User user = Provider
        .of<UserProvider>(context)
        .user;


    return new Scaffold(
        appBar: new AppBar(title: new Text(AppLocalizations.of(context)!.activityCalendar)),
        body: _getCalendarSection(user)
    );
  }

  Widget _getCalendarSection(user) {
    switch (_loadingState) {
      case LoadingState.DONE:
      //data loaded
        return _getCalendarContent(user);

      case LoadingState.ERROR:
      //data loading returned error state
        return Align(alignment: Alignment.center,
          child: ListTile(
            leading: Icon(Icons.error),
            title: Text(
                'Sorry, there was an error loading the data: $errormessage'),
          ),
        );

      case LoadingState.LOADING:
       // if (!_isLoading) _loadCalendarEvents(user);
        //data loading in progress
        return Align(alignment: Alignment.center,
          child: Center(
            child: ListTile(
              leading: CircularProgressIndicator(),
              title: Text(AppLocalizations.of(context)!.loading,
                  textAlign: TextAlign.center),
            ),
          ),
        );
      default:
        return Container();
    }
  }

  Widget _getCalendarContent(user) {
    final kNow = DateTime.now();
     kFirstDay = DateTime(kNow.year, kNow.month - 1, kNow.day);
     kLastDay = DateTime(kNow.year, kNow.month + 3, kNow.day);
    return Column(
        children: [
          TableCalendar<Activity>(
            firstDay: kFirstDay ?? kNow,
            lastDay: kLastDay ?? kNow,
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            startingDayOfWeek: StartingDayOfWeek.monday,
            selectedDayPredicate: (day) {
              // Use `selectedDayPredicate` to determine which day is currently selected.
              // If this returns true, then `day` will be marked as selected.

              // Using `isSameDay` is recommended to disregard
              // the time-part of compared DateTime objects.
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: _onDaySelected,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                // Call `setState()` when updating calendar format
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              // No need to call `setState()` here
              _focusedDay = focusedDay;
            },
            eventLoader: _getEventsForDay,
          ), const SizedBox(height: 8.0),
          Expanded(
            child: ValueListenableBuilder<List<Activity>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                print(value);
                return ListView.builder(
                    itemCount: value.length,
                    itemBuilder: (BuildContext context, int index) {


                      return ActivityListItem(value[index]);
                    });
              },
            ),
          ),
        ],
      );

  }
}