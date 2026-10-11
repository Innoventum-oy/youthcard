import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youth_card/l10n/app_localizations.dart';
import 'package:youth_card/src/views/welcome.dart';

void main() {
  testWidgets('welcome screen shows a route forward', (tester) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Welcome(),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(FilledButton), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });
}
