import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:youth_card/src/objects/activity.dart';
import 'package:youth_card/src/objects/activityclass.dart';
import 'package:youth_card/src/providers/activity_class_provider.dart';
import 'package:youth_card/src/providers/activity_list_provider.dart';
import 'package:youth_card/src/util/file_storage_interface.dart';

class MemoryFileStorage implements FileStorageInterface {
  final values = <String, dynamic>{};
  DateTime now = DateTime(2026, 10, 11);
  final savedAt = <String, DateTime>{};

  @override
  Future<dynamic> read(String filename, {int expiration = 0}) async {
    if (!values.containsKey(filename)) return false;
    if (expiration != 0 &&
        now.difference(savedAt[filename]!) >= Duration(minutes: expiration)) {
      return false;
    }
    return values[filename];
  }

  @override
  Future<bool> write(dynamic data, String filename) async {
    values[filename] = (data as List).map((item) => item.toJson()).toList();
    savedAt[filename] = now;
    return true;
  }

  @override
  Future<void> clear() async => values.clear();

  @override
  Future<void> delete(String filename) async => values.remove(filename);
}

void main() {
  test('reopening the calendar uses memory, then persisted data', () async {
    final storage = MemoryFileStorage();
    var remoteCalls = 0;
    Future<List<Activity>> remote(Map<String, dynamic> _) async {
      remoteCalls++;
      return [
        Activity(
          id: 7,
          name: 'Workshop',
          nexteventdate: DateTime(2026, 10, 18),
          coverpictureurl: 'https://example.org/workshop.jpg',
        ),
      ];
    }

    ActivityListProvider provider() => ActivityListProvider(
      loadRemote: remote,
      storage: storage,
      serverName: () async => 'test',
      clock: () => storage.now,
    );

    final first = provider();
    final a = await first.loadItems({
      'view': 'calendar',
      'startfrom': '2026-09-01',
    });
    final b = await first.loadItems({
      'startfrom': '2026-09-01',
      'view': 'calendar',
    });
    expect(identical(a, b), isTrue);
    expect(remoteCalls, 1);

    final reopened = await provider().loadItems({
      'view': 'calendar',
      'startfrom': '2026-09-01',
    });
    expect(remoteCalls, 1);
    expect(reopened.single.nexteventdate, DateTime(2026, 10, 18));
    expect(reopened.single.coverpictureurl, 'https://example.org/workshop.jpg');
  });

  test(
    'refresh bypasses fresh cache and offline refresh retains saved events',
    () async {
      final storage = MemoryFileStorage();
      var remoteCalls = 0;
      var offline = false;
      final provider = ActivityListProvider(
        loadRemote: (_) async {
          remoteCalls++;
          if (offline) throw StateError('offline');
          return [Activity(id: remoteCalls, name: 'Event')];
        },
        storage: storage,
        serverName: () async => 'test',
        clock: () => storage.now,
      );
      final params = {'view': 'calendar'};
      expect((await provider.loadItems(params)).single.id, 1);
      expect((await provider.loadItems(params, refresh: true)).single.id, 2);
      offline = true;
      storage.now = storage.now.add(const Duration(hours: 1));
      expect((await provider.loadItems(params, refresh: true)).single.id, 2);
      expect(remoteCalls, 3);
    },
  );

  test('simultaneous calendar requests share one network request', () async {
    final storage = MemoryFileStorage();
    final completer = Completer<List<Activity>>();
    var remoteCalls = 0;
    final provider = ActivityListProvider(
      loadRemote: (_) {
        remoteCalls++;
        return completer.future;
      },
      storage: storage,
      serverName: () async => 'test',
      clock: () => storage.now,
    );
    final first = provider.loadItems({'view': 'calendar'});
    final second = provider.loadItems({'view': 'calendar'});
    await Future<void>.delayed(Duration.zero);
    completer.complete([Activity(id: 1)]);
    expect((await first).single.id, 1);
    expect((await second).single.id, 1);
    expect(remoteCalls, 1);
  });

  test(
    'discovery categories reopen from persisted cache with thumbnails',
    () async {
      final storage = MemoryFileStorage();
      var remoteCalls = 0;
      ActivityClassProvider provider() => ActivityClassProvider(
        storage: storage,
        loadRemote: (_) async {
          remoteCalls++;
          return [
            ActivityClass(
              id: 3,
              name: 'Creative workshops',
              coverpictureurl: 'https://example.org/category.jpg',
              accesslevel: 10,
            ),
          ];
        },
      );
      final params = {'loadmethod': 'loadActivityClassesWithActivities'};
      await provider().loadItems(params);
      final reopened = await provider().loadItems(params);
      expect(remoteCalls, 1);
      expect(
        reopened.single.coverpictureurl,
        'https://example.org/category.jpg',
      );
      expect(reopened.single.accesslevel, 10);
    },
  );

  test('cache round trip keeps missing event dates missing', () {
    final activity = Activity(id: 5, name: 'Undated');
    final restored = Activity.fromJson(
      Map<String, dynamic>.from(activity.toJson()),
    );
    expect(restored.startdate, isNull);
    expect(restored.nexteventdate, isNull);
  });
}
