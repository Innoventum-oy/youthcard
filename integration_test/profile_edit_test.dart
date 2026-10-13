import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:youth_card/l10n/app_localizations.dart';
import 'package:youth_card/main.dart' as app;
import 'package:youth_card/src/providers/auth.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/util/app_url.dart';
import 'package:youth_card/src/util/shared_preference.dart';
import 'package:youth_card/src/views/card.dart';
import 'package:youth_card/src/views/dashboard.dart';
import 'package:youth_card/src/views/userform.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('production demo account can edit its profile', (tester) async {
    final credentials = await tester.runAsync(_getCredentials);
    app.main();
    await tester.pump(const Duration(seconds: 1));
    expect(
      await tester.runAsync(() => Settings().getServer()),
      AppUrl.productionServerHost,
    );

    final context = app.NavigationService.navigatorKey.currentContext!;
    final auth = context.read<AuthProvider>();
    final response = await tester.runAsync(
      () => auth.login(
        credentials!['SCREENSHOT_DEMO_EMAIL']!,
        credentials['SCREENSHOT_DEMO_PASSWORD']!,
        server: AppUrl.productionServerHost,
      ),
    );
    expect(response?['status'], isTrue);
    app.NavigationService.navigatorKey.currentContext!
        .read<UserProvider>()
        .setUser(response!['user']);
    app.NavigationService.navigatorKey.currentState!.pushReplacementNamed(
      '/dashboard',
    );
    await _waitFor(tester, find.byType(DashBoard));
    await _settleRoute(tester);
    final nav = find.descendant(
      of: find.byKey(const ValueKey('store-bottom-nav')),
      matching: find.byType(InkWell),
    );
    expect(nav, findsNWidgets(4));
    await tester.tap(nav.at(3));
    await _waitFor(tester, find.byType(MyCard));
    await _settleRoute(tester);

    final editLabel = AppLocalizations.of(
      tester.element(find.byType(MyCard)),
    )!.btnEdit;
    await tester.tap(find.text(editLabel));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(UserForm), findsOneWidget);

    for (var attempt = 0; attempt < 20; attempt++) {
      if (tester.any(find.byType(TextFormField))) break;
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(seconds: 1)),
      );
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(tester.takeException(), isNull);
    expect(find.byType(TextFormField), findsWidgets);
  });
}

Future<void> _waitFor(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 80; attempt++) {
    await tester.pump(const Duration(milliseconds: 250));
    if (tester.any(finder)) return;
  }
  throw TestFailure('Screen did not open: $finder');
}

Future<void> _settleRoute(WidgetTester tester) async {
  for (var attempt = 0; attempt < 5; attempt++) {
    await tester.pump(const Duration(milliseconds: 250));
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
      throw TestFailure('Could not load the demo account');
    }
    final body = await response.transform(utf8.decoder).join();
    final values = jsonDecode(body) as Map<String, dynamic>;
    return values.map((key, value) => MapEntry(key, value.toString()));
  } finally {
    client.close();
  }
}
