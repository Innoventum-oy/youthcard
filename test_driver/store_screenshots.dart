import 'dart:convert';
import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() async {
  final root = Platform.environment['SCREENSHOT_OUTPUT_DIR'];
  final device = Platform.environment['SCREENSHOT_DEVICE'];
  final definesFile = Platform.environment['SCREENSHOT_DEFINES_FILE'];
  if (root == null || root.isEmpty) {
    throw StateError('Set SCREENSHOT_OUTPUT_DIR before capturing screenshots');
  }
  if (device == null || device.isEmpty) {
    throw StateError('Set SCREENSHOT_DEVICE before capturing screenshots');
  }
  if (definesFile == null || !File(definesFile).existsSync()) {
    throw StateError(
      'Set SCREENSHOT_DEFINES_FILE to the private demo-account JSON file',
    );
  }
  final credentials = jsonDecode(File(definesFile).readAsStringSync());
  if (credentials is! Map ||
      credentials['SCREENSHOT_DEMO_EMAIL'] is! String ||
      credentials['SCREENSHOT_DEMO_PASSWORD'] is! String) {
    throw StateError('Screenshot demo account JSON is incomplete');
  }
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 49342);
  server.listen((request) async {
    final name = request.uri.queryParameters['name'] ?? '';
    if (request.uri.path == '/credentials') {
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode(credentials));
    } else if (request.uri.path != '/capture' ||
        !RegExp(r'^\d{2}_[a-z_]+$').hasMatch(name)) {
      request.response.statusCode = HttpStatus.badRequest;
    } else {
      final file = File('$root/$name.png');
      file.parent.createSync(recursive: true);
      final result = await Process.run('xcrun', [
        'simctl',
        'io',
        device,
        'screenshot',
        file.path,
      ]);
      if (result.exitCode != 0) {
        request.response.statusCode = HttpStatus.internalServerError;
        request.response.write(result.stderr);
      }
    }
    await request.response.close();
  });
  try {
    await integrationDriver();
  } finally {
    await server.close(force: true);
  }
}
