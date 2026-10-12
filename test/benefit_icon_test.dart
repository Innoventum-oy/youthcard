import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youth_card/src/util/benefit_icon.dart';

void main() {
  testWidgets('benefit icon shows a placeholder when the image is rejected', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: BenefitIcon(url: 'https://example.com/icon.png')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.local_offer_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('benefit icon handles an absent URL', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: BenefitIcon())),
    );

    expect(find.byIcon(Icons.local_offer_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
