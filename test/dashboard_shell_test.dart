import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:core/core.dart' as core;
import 'package:provider/provider.dart';
import 'package:youth_card/l10n/app_localizations.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/util/widgets.dart';

void main() {
  test('Core app settings are bundled with the application', () async {
    final config = await rootBundle.loadString(
      'assets/config/appsettings.yaml',
    );
    expect(config, contains('appName: Youth Card'));
    expect(config, contains('servers:'));
    expect(await core.AppSettings().get('appName'), 'Youth Card');
  });

  testWidgets('dashboard navigation stays compact on a phone', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final userProvider = UserProvider()..setUserSilent(User(token: 'test'));
    await tester.pumpWidget(
      ChangeNotifierProvider<UserProvider>.value(
        value: userProvider,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: const Center(child: Text('Dashboard content')),
              bottomNavigationBar: bottomNavigation(context),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final nav = find.byWidgetPredicate(
      (widget) => widget is SizedBox && widget.height == 56,
    );
    expect(nav, findsOneWidget);
    expect(tester.getSize(nav).height, 56);
    expect(find.text('Dashboard content'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Discover'), findsOneWidget);
    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('My Card'), findsOneWidget);
  });
}
