import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';

import '../objects/activity.dart';
import '../objects/activitydate.dart';
import '../util/local_storage.dart';
import '../util/file_storage_interface.dart';
import '../util/shared_preference.dart';
import 'objectprovider.dart';

class ActivityListProvider extends ObjectProvider {

  ActivityListProvider({
    Future<List<Activity>> Function(Map<String, dynamic>)? loadRemote,
    FileStorageInterface? storage,
    Future<String> Function()? serverName,
    DateTime Function()? clock,
  }) : _loadRemote = loadRemote ?? ApiClient().loadActivities,
       _storage = storage ?? getFileStorage(),
       _serverName = serverName ?? Settings().getServerName,
       _clock = clock ?? DateTime.now;

  static const cacheLifetime = Duration(minutes: 30);
  final Future<List<Activity>> Function(Map<String, dynamic>) _loadRemote;
  final FileStorageInterface _storage;
  final Future<String> Function() _serverName;
  final DateTime Function() _clock;
  final Map<String, _ActivitySnapshot> _memory = {};
  final Map<String, Future<List<Activity>>> _inFlight = {};

  void clearMemoryCache() {
    _memory.clear();
    _inFlight.clear();
    _data = null;
  }
  List<Activity>? _data;
  List<Activity>? get list => _data;
  final ApiClient _apiClient = ApiClient();
  Future<void> loadMyItems() async
  {
    DateTime now = DateTime.now();
    final Map<String, String> params = {
      'accesslevel':'modify',
      'activitystatus': 'active',
      'api_key': user.token ?? await Settings().getValue("anonymousapikey"),
      'gte:startdate': DateFormat('yyyy-MM-dd').format(now),
      'grouping':'activity.id'
    };
    _data = await loadItems(params,refresh:true);
  }


  @override
  Future<List<Activity>> loadItems(dynamic params,{bool refresh = false}) async {
    final entries = (params as Map).entries
        .map((entry) => MapEntry(entry.key.toString(), entry.value))
        .toList()..sort((a, b) => a.key.compareTo(b.key));
    final sortedParams = <String, dynamic>{for (final entry in entries) entry.key: entry.value};
    final filename = 'activities_${md5.convert(utf8.encode(jsonEncode(sortedParams)))}';
    final key = '${await _serverName()}:$filename';
    final snapshot = _memory[key];
    if (!refresh && snapshot != null && _clock().isBefore(snapshot.expiresAt)) {
      _data = snapshot.items;
      return snapshot.items;
    }
    if (_inFlight[key] case final pending?) return pending;

    final pending = _loadAndCache(key, filename, sortedParams,
        refresh: refresh, staleMemory: snapshot);
    _inFlight[key] = pending;
    try {
      return await pending;
    } finally {
      _inFlight.remove(key);
    }
  }

  Future<List<Activity>> _loadAndCache(
    String key,
    String filename,
    Map<String, dynamic> params, {
    required bool refresh,
    _ActivitySnapshot? staleMemory,
  }) async {
    final cached = await _storage.read(filename, expiration: 30);
    if (cached is List && !refresh) {
      final items = _decodeActivities(cached);
      _remember(key, items);
      return items;
    }
    try {
      final remote = await _loadRemote(params);
      _remember(key, remote);
      await _storage.write(remote, filename);
      notifyListeners();
      return remote;
    } catch (_) {
      if (staleMemory != null) {
        _data = staleMemory.items;
        return staleMemory.items;
      }
      final stale = cached is List ? cached : await _storage.read(filename);
      if (stale is List) {
        final items = _decodeActivities(stale);
        _remember(key, items);
        return items;
      }
      rethrow;
    }
  }

  List<Activity> _decodeActivities(List cached) => cached
      .map((data) => Activity.fromJson(Map<String, dynamic>.from(data)))
      .toList();

  void _remember(String key, List<Activity> items) {
    _data = items;
    _memory[key] = _ActivitySnapshot(items, _clock().add(cacheLifetime));
  }

  Future<dynamic> getActivityDates(Activity activity, user) async{

    final remoteactivitydatedata =  await _apiClient.loadActivitydates(activity,user);

    return remoteactivitydatedata;
  }


  Future<dynamic> getActivityUsers(int activityId,user) async{
    final remoteactivityuserdata =  await _apiClient.loadActivityUsers(activityId,user);

    return remoteactivityuserdata;
  }

  Future<dynamic> getActivityDateVisits(int activityId,ActivityDate date,user) async{
    final remoteactivityvisitdata =  await _apiClient.loadActivityDateVisits(activityId,date,user);

    return remoteactivityvisitdata;
  }

  // returns json-decoded response
  @override
  Future<dynamic> getDetails(int activityId, user,{reload =false}) async {

    if(!reload) {
      final activitydata = await getFileStorage().read(
          "activity_${activityId}_user_${user.id}",
          expiration: 30);
      if (activitydata != false) {

        return activitydata;
      }
    }

    final key = "activity_${activityId}_user_${user.id}";
    try {
      final remoteActivityData = await _apiClient.getActivityDetails(activityId, user);
      await getFileStorage().write(remoteActivityData, key);
      return remoteActivityData;
    } catch (_) {
      final stale = await getFileStorage().read(key);
      if (stale != false) return stale;
      rethrow;
    }

  }
}

class _ActivitySnapshot {
  const _ActivitySnapshot(this.items, this.expiresAt);

  final List<Activity> items;
  final DateTime expiresAt;
}
