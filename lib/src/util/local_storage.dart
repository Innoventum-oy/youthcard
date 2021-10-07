import 'package:path_provider/path_provider.dart';
import 'package:youth_card/src/util/shared_preference.dart';
import 'dart:io';
import 'dart:convert';
import 'package:glob/glob.dart';
import 'dart:async';
//import 'package:shared_preferences/shared_preferences.dart';

class FileStorage {
  static Future<bool> write(dynamic data, String filename) async {
    final servername = await Settings().getServerName();

    final file = File(
        '${(await getApplicationDocumentsDirectory()).path}/$servername.$filename.json');
    file.writeAsString(jsonEncode(data));
    return true;
  }

  static Future<dynamic> read(String filename, {int expiration = 0}) async {
    final servername = await Settings().getServerName();
    final file = File(
        '${(await getApplicationDocumentsDirectory()).path}/$servername.$filename.json');
    if (await file.exists()) {
      if (expiration == 0)
        return jsonDecode(await file.readAsString());
      else {
        DateTime date = await file.lastModified();
        if (date.difference(new DateTime.now()).inMinutes < expiration)
          return jsonDecode(await file.readAsString());
        else {
          print("Expiring $filename");
          return delete(filename);
          }
        }
    }
    return false;
  }
  static void clear() async {
    final servername = await Settings().getServerName();

    final filemask = Glob("${(await getApplicationDocumentsDirectory()).path}/$servername.*.json");
    Directory dir = await getApplicationDocumentsDirectory();
    print("clearing with mask " + filemask.toString());
    var directoryListing = dir.listSync().where((e) => e is File);
    for (var directoryEntry in directoryListing)
    {
             directoryEntry.delete();
             print("deleted "+ directoryEntry.toString());

    }
   /* SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
*/
  }
    static void delete(String filename) async {
      final servername = await Settings().getServerName();

      final file = File(
        '${(await getApplicationDocumentsDirectory()).path}/$servername.$filename.json');
    if (await file.exists()) {
      print('removing file $servername.$filename.json from local storage');
      file.delete();
    }
  }
}
