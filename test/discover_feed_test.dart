import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:youth_card/l10n/app_localizations.dart';
import 'package:youth_card/src/objects/activity.dart';
import 'package:youth_card/src/objects/activityclass.dart';
import 'package:youth_card/src/providers/activity_class_provider.dart';
import 'package:youth_card/src/providers/activity_list_provider.dart';
import 'package:youth_card/src/providers/image_provider.dart' as app_images;
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/views/activity/categorisedactivitylist.dart';
import 'package:youth_card/src/views/activity/activity_category_browser.dart';

class _DiscoverActivities extends ActivityListProvider {
  final requests = <Map<String, dynamic>>[];

  @override
  Future<List<Activity>> loadItems(
    dynamic params, {
    bool refresh = false,
  }) async {
    final request = Map<String, dynamic>.from(params as Map);
    requests.add(request);
    if (request['activitytype'] == 'location') {
      return [
        Activity(
          id: 3,
          name: 'City library',
          city: 'Joensuu',
          address: 'Library Road 2',
          activityType: 'location',
        ),
        Activity(
          id: 4,
          name: 'Empty field',
          address: 'Field Road 8',
          activityType: 'location',
        ),
      ];
    }
    return [
      Activity(id: 1, name: 'Creative weekend', address: 'Library Road 2'),
      Activity(id: 2, name: 'Youth sports club', address: 'Sports Street 1'),
    ];
  }
}

class _Categories extends ActivityClassProvider {
  @override
  Future<List<ActivityClass>> loadItems(
    dynamic params, {
    bool refresh = false,
  }) async => [ActivityClass(id: 7, name: 'Music')];
}

void main() {
  testWidgets('Discover loads one page per type and filters the mixed feed', (
    tester,
  ) async {
    final provider = _DiscoverActivities();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider<ActivityListProvider>.value(value: provider),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: CategorisedActivityList(app_images.ImageProvider()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(provider.requests.length, 2);
    expect(
      provider.requests.map((request) => request['activitytype']).toSet(),
      {'activity', 'location'},
    );
    expect(find.text('Creative weekend'), findsOneWidget);
    expect(find.text('City library'), findsOneWidget);
    expect(find.text('Empty field'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('discover-filter-places')));
    await tester.pumpAndSettle();
    expect(find.text('City library'), findsOneWidget);
    expect(find.text('Creative weekend'), findsNothing);
    expect(provider.requests.length, 2);

    await tester.tap(find.text('City library'));
    await tester.pumpAndSettle();
    expect(provider.requests.last['address'], 'Library Road 2');
    expect(find.text('Creative weekend'), findsOneWidget);
    expect(find.text('Youth sports club'), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('discover-filter-activities')));
    await tester.pumpAndSettle();
    expect(find.text('Creative weekend'), findsOneWidget);
    expect(find.text('City library'), findsNothing);
    expect(provider.requests.length, 3);
  });

  testWidgets('category events load only after opening a category', (
    tester,
  ) async {
    final provider = _DiscoverActivities();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider<ActivityListProvider>.value(value: provider),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ActivityCategoryBrowser(
            app_images.ImageProvider(),
            categoryProvider: _Categories(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(provider.requests, isEmpty);

    await tester.tap(find.text('Music'));
    await tester.pumpAndSettle();
    expect(provider.requests.length, 1);
    expect(provider.requests.single['activityclass'], 'id:7');
  });
}
