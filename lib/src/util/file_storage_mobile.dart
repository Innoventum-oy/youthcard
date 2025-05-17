
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
    file.writeAsString(jsonEncode(data));
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
        if (date.difference(DateTime.now()).inMinutes < expiration) {
          return jsonDecode(await file.readAsString());
        } else {

          return delete(filename);
        }
      }
    }
    return false;
  }

  @override
  Future<void> clear() async {

    Directory dir = await getApplicationDocumentsDirectory();

    var directoryListing = dir.listSync().whereType<File>();
    for (var directoryEntry in directoryListing)
    {
      directoryEntry.delete();


    }
    /* SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
*/
  }
  @override
  Future<void> delete(String filename) async {
    final servername = await Settings().getServerName();

    final file = File(
        '${(await getApplicationDocumentsDirectory()).path}/$servername.$filename.json');
    if (await file.exists()) {

      file.delete();
    }
  }

}
FileStorageInterface getPlatformFileStorage() => MobileFileStorage();