import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

import 'dart:async';

class FileStorage {
  static Future<bool> write(dynamic data, String filename) async {
    final file = File('${(await getApplicationDocumentsDirectory()).path}/$filename.json');
    file.writeAsString(jsonEncode(data));
    return true;
  }

  static Future<dynamic> read(String filename) async {
    final file = File('${(await getApplicationDocumentsDirectory()).path}/$filename.json');
    if (await file.exists()) {
    return jsonDecode(await file.readAsString());
    }
    return false;
  }
  static void delete(String filename) async {
    final file = File('${(await getApplicationDocumentsDirectory()).path}/$filename.json');
    if (await file.exists()) {
      print('removing file from local storage');
    file.delete();
    }
  }
}

