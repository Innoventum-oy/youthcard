// lib/src/util/file_storage_web.dart
import 'file_storage_interface.dart';
import 'dart:convert';
import 'dart:html';

class WebFileStorage implements FileStorageInterface {
  @override
  Future<bool> write(dynamic data, String filename) async {
    window.localStorage[filename] = jsonEncode(data);
    return true;
  }

  @override
  Future<dynamic> read(String filename, {int expiration = 0}) async {
    final value = window.localStorage[filename];
    if (value != null) {
      return jsonDecode(value);
    }
    return false;
  }

  @override
  Future<void> clear() async {
    window.localStorage.clear();
  }

  @override
  Future<void> delete(String filename) async {
    window.localStorage.remove(filename);
  }

}
FileStorageInterface getPlatformFileStorage() => WebFileStorage();

