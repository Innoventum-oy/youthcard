import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../objects/activityclass.dart';
import '../util/file_storage_interface.dart';
import '../util/local_storage.dart';
import 'objectprovider.dart';

class ActivityClassProvider extends ObjectProvider {
  ActivityClassProvider({
    Future<List<ActivityClass>> Function(Map<String, dynamic>)? loadRemote,
    FileStorageInterface? storage,
  }) : _loadRemote = loadRemote ?? ApiClient().loadActivityClasses,
       _storage = storage ?? getFileStorage();

  final Future<List<ActivityClass>> Function(Map<String, dynamic>) _loadRemote;
  final FileStorageInterface _storage;
  final Map<String, Future<List<ActivityClass>>> _inFlight = {};

  @override
  Future<List<ActivityClass>> loadItems(
    dynamic params, {
    bool refresh = false,
  }) async {
    final entries =
        (params as Map).entries
            .map((entry) => MapEntry(entry.key.toString(), entry.value))
            .toList()
          ..sort((a, b) => a.key.compareTo(b.key));
    final sortedParams = <String, dynamic>{
      for (final entry in entries) entry.key: entry.value,
    };
    final filename =
        'activityclasses_${md5.convert(utf8.encode(jsonEncode(sortedParams)))}';
    final pending = _inFlight[filename];
    if (pending != null) return pending;
    final loading = _loadAndCache(filename, sortedParams, refresh: refresh);
    _inFlight[filename] = loading;
    try {
      return await loading;
    } finally {
      _inFlight.remove(filename);
    }
  }

  Future<List<ActivityClass>> _loadAndCache(
    String filename,
    Map<String, dynamic> params, {
    required bool refresh,
  }) async {
    final cached = await _storage.read(filename, expiration: 30);
    if (!refresh && cached is List) return _decode(cached);
    try {
      final classes = await _loadRemote(params);
      await _storage.write(classes, filename);
      return classes;
    } catch (_) {
      final stale = cached is List ? cached : await _storage.read(filename);
      if (stale is List) return _decode(stale);
      rethrow;
    }
  }

  List<ActivityClass> _decode(List cached) => cached
      .map((data) => ActivityClass.fromJson(Map<String, dynamic>.from(data)))
      .toList();

  @override
  Future<dynamic> getDetails(int activityClassId, user) =>
      ApiClient().getActivityClassDetails(activityClassId, user);
}
