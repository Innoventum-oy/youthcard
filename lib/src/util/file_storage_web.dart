// lib/src/util/file_storage_web.dart
import 'file_storage_interface.dart';
import 'dart:convert';
import 'dart:html';
import 'package:youth_card/src/util/shared_preference.dart';

class WebFileStorage implements FileStorageInterface {
  Future<String> _key(String filename) async =>
      '${await Settings().getServerName()}.$filename';

  @override
  Future<bool> write(dynamic data, String filename) async {
    window.localStorage[await _key(filename)] = jsonEncode({
      '_cachedAt': DateTime.now().millisecondsSinceEpoch,
      '_value': data,
    });
    return true;
  }

  @override
  Future<dynamic> read(String filename, {int expiration = 0}) async {
    final value = window.localStorage[await _key(filename)] ??
        (filename == 'local_user' ? window.localStorage[filename] : null);
    if (value != null) {
      final decoded = jsonDecode(value);
      if (decoded is Map && decoded.containsKey('_cachedAt') && decoded.containsKey('_value')) {
        if (expiration > 0 &&
            DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(decoded['_cachedAt'] as int)) >=
                Duration(minutes: expiration)) {
          return false;
        }
        return decoded['_value'];
      }
      // Old entries have no timestamp, so only use them as an offline fallback.
      return expiration == 0 ? decoded : false;
    }
    return false;
  }

  @override
  Future<void> clear() async {
    final prefix = '${await Settings().getServerName()}.';
    final keys = window.localStorage.keys.where(
      (key) => key.startsWith(prefix) && !key.endsWith('.local_user'),
    ).toList();
    for (final key in keys) {
      window.localStorage.remove(key);
    }
  }

  @override
  Future<void> delete(String filename) async {
    window.localStorage.remove(await _key(filename));
    if (filename == 'local_user') window.localStorage.remove(filename);
  }

}
FileStorageInterface getPlatformFileStorage() => WebFileStorage();
