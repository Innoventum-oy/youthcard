import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:youth_card/main.dart' as app;
import 'package:youth_card/src/providers/auth.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/views/activity/categorisedactivitylist.dart';
import 'package:youth_card/src/views/activity/activity.dart';
import 'package:youth_card/src/views/card.dart';
import 'package:youth_card/src/views/dashboard.dart';
import 'package:youth_card/src/util/app_url.dart';

const _target = String.fromEnvironment('SCREENSHOT_TARGET', defaultValue: 'iphone_61');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture the localized Youth Card store views', (tester) async {
    final credentials = await tester.runAsync(_getCredentials);
    expect(credentials, isNotNull);
    app.main();
    await _waitFor(tester, find.byType(MaterialApp));

    final context = app.NavigationService.navigatorKey.currentContext!;
    final auth = context.read<AuthProvider>();
    final response = await tester.runAsync(
      () => auth.login(
        credentials!['SCREENSHOT_DEMO_EMAIL']!,
        credentials['SCREENSHOT_DEMO_PASSWORD']!,
        server: AppUrl.productionServerHost,
      ),
    );
    expect(response, isNotNull);
    expect(response!['status'], isTrue, reason: 'Production demo login failed');
    context.read<UserProvider>().setUser(response['user']);
    app.NavigationService.navigatorKey.currentState!.pushReplacementNamed(
      '/dashboard',
    );

    await _waitFor(tester, find.byType(DashBoard));
    await _settleRoute(tester);
    await _contentLoad(tester);
    await tester.runAsync(() => _capture('01_dashboard'));

    await _navigate(tester, 1, find.byType(CategorisedActivityList));
    await _waitForNoSpinner(tester, find.byType(CategorisedActivityList));
    await _contentLoad(tester);
    await tester.runAsync(() => _capture('02_discover'));

    await tester.tap(find.byKey(ValueKey(
      _target == 'iphone_61' ? 'discover-card-1' : 'discover-card-0',
    )));
    await _waitFor(tester, find.byType(ActivityView));
    await _settleRoute(tester);
    await _contentLoad(tester);
    await tester.runAsync(() => _capture('03_event_detail'));
    app.NavigationService.navigatorKey.currentState!.pop();
    await _waitFor(tester, find.byType(CategorisedActivityList));
    await _settleRoute(tester);

    await _navigate(tester, 3, find.byType(MyCard));
    await _contentLoad(tester);
    await tester.runAsync(() => _capture('04_my_card'));
  });
}

Future<void> _navigate(
  WidgetTester tester,
  int index,
  Finder destination,
) async {
  final bar = find.descendant(
    of: find.byKey(const ValueKey('store-bottom-nav')),
    matching: find.byType(InkWell),
  );
  expect(bar, findsNWidgets(4));
  await tester.tap(bar.at(index));
  await _waitFor(tester, destination);
  await _settleRoute(tester);
}

Future<void> _waitFor(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 80; i++) {
    await tester.pump(const Duration(milliseconds: 250));
    if (tester.any(finder)) return;
  }
  throw TestFailure('Screen did not open: $finder');
}

Future<void> _contentLoad(WidgetTester tester) async {
  await tester.runAsync(() => Future<void>.delayed(const Duration(seconds: 2)));
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _settleRoute(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 250));
  }
}

Future<void> _waitForNoSpinner(WidgetTester tester, Finder screen) async {
  final spinner = find.descendant(
    of: screen,
    matching: find.byType(CircularProgressIndicator),
  );
  for (var i = 0; i < 45; i++) {
    await tester.pump(const Duration(milliseconds: 250));
    if (!tester.any(spinner)) return;
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 1)),
    );
  }
  throw TestFailure('Content did not finish loading: $screen');
}

Future<void> _capture(String name) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(
      Uri.parse('http://127.0.0.1:49342/capture?name=$name'),
    );
    final response = await request.close();
    final body = await response
        .transform(const SystemEncoding().decoder)
        .join();
    if (response.statusCode != HttpStatus.ok) {
      throw TestFailure('Simulator capture failed for $name: $body');
    }
  } finally {
    client.close();
  }
}

Future<Map<String, String>> _getCredentials() async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(
      Uri.parse('http://127.0.0.1:49342/credentials'),
    );
    final response = await request.close();
    if (response.statusCode != HttpStatus.ok) {
      throw TestFailure('Could not load screenshot demo account');
    }
    final body = await response.transform(utf8.decoder).join();
    final values = jsonDecode(body) as Map<String, dynamic>;
    return values.map((key, value) => MapEntry(key, value.toString()));
  } finally {
    client.close();
  }
}
