import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:youth_card/l10n/app_localizations.dart';
import 'package:youth_card/src/objects/activity.dart';
import 'package:youth_card/src/objects/activityclass.dart';
import 'package:youth_card/src/providers/activity_list_provider.dart';
import 'package:youth_card/src/providers/index.dart' as app_providers;
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/views/activity/activitylistsliver.dart';

class _ActivityProvider extends ActivityListProvider {
  _ActivityProvider(this.activities);

  final List<Activity> activities;

  @override
  Future<List<Activity>> loadItems(
    dynamic params, {
    bool refresh = false,
  }) async => activities;
}

void main() {
  Future<void> pumpCategory(
    WidgetTester tester,
    List<Activity> activities,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => UserProvider(),
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ActivityListSliver(
                    _ActivityProvider(activities),
                    app_providers.ImageProvider(),
                    ActivityClass(id: 1, name: 'Music'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('empty category occupies only a compact row', (tester) async {
    await pumpCategory(tester, []);
    final height = tester.getSize(find.byType(ActivityListSliver)).height;
    expect(height, lessThan(80));
    expect(find.text('Could not find any activities'), findsOneWidget);
  });

  testWidgets('category with events keeps thumbnail carousel', (tester) async {
    await pumpCategory(tester, [Activity(id: 1, name: 'Workshop')]);
    expect(tester.getSize(find.byType(ActivityListSliver)).height, 260);
    expect(find.text('Workshop'), findsOneWidget);
  });
}
