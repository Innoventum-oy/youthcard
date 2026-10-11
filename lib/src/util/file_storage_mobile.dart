
import 'file_storage_interface.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youth_card/src/util/shared_preference.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';

class MobileFileStorage implements FileStorageInterface {

  @override
  Future<bool> write(dynamic data, String filename) async {
    final servername = await Settings().getServerName();

    final file = File(
        '${(await getApplicationDocumentsDirectory()).path}/$servername.$filename.json');
    await file.writeAsString(jsonEncode(data), flush: true);
    return true;
  }

  @override
  Future<dynamic> read(String filename, {int expiration = 0}) async {
    final servername = await Settings().getServerName();
    final file = File(
        '${(await getApplicationDocumentsDirectory()).path}/$servername.$filename.json');
    if (await file.exists()) {
      if (expiration == 0) {
        return jsonDecode(await file.readAsString());
      } else {
        DateTime date = await file.lastModified();
        if (DateTime.now().difference(date) < Duration(minutes: expiration)) {
          return jsonDecode(await file.readAsString());
        } else {
          // Retain stale data for an offline fallback.
          return false;
        }
      }
    }
    return false;
  }

  @override
  Future<void> clear() async {

    final servername = await Settings().getServerName();
    final dir = await getApplicationDocumentsDirectory();
    await for (final entry in dir.list()) {
      if (entry is File &&
          entry.path.split(Platform.pathSeparator).last.startsWith('$servername.') &&
          !entry.path.endsWith('.local_user.json')) {
        await entry.delete();
      }
    }
  }
  @override
  Future<void> delete(String filename) async {
    final servername = await Settings().getServerName();

    final file = File(
        '${(await getApplicationDocumentsDirectory()).path}/$servername.$filename.json');
    if (await file.exists()) {

      await file.delete();
    }
  }

}
FileStorageInterface getPlatformFileStorage() => MobileFileStorage();
