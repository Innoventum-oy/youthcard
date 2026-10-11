import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:youth_card/l10n/app_localizations.dart';
import 'package:youth_card/src/objects/activity.dart';
import 'package:youth_card/src/objects/activitydate.dart';
import 'package:youth_card/src/providers/activity_list_provider.dart';
import 'package:youth_card/src/providers/image_provider.dart' as app_images;
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/views/activity/activity.dart';
import 'package:youth_card/src/views/meta_section.dart';

class _DetailsProvider extends ActivityListProvider {
  @override
  Future<dynamic> getDetails(
    int activityId,
    dynamic user, {
    reload = false,
  }) async {
    return {
      'id': '$activityId',
      'name': 'Liikuntakerho tiistaisin',
      'description': 'Kerhossa liikutaan monipuolisesti leikkien ja pelaillen.',
      'nexteventdate': DateTime.now()
          .add(const Duration(days: 1))
          .toIso8601String(),
      'address': 'Patteristontie 12',
      'postcode': '80400',
      'city': 'Liperi',
      'agemin': '10',
      'agemax': '12',
      'registeredvisitorcount': '1',
      'maxvisitors': '16',
      'price': '0.00',
      'organizer': {'name': 'Harrastamisen Liperin malli'},
      'contactinfo': '<p>Harrastekoordinaattori: Ria Raippa</p>',
      'accesslevel': '0',
    };
  }

  @override
  Future<dynamic> getActivityDates(Activity activity, dynamic user) async => [
    ActivityDate(
      id: 1,
      activityid: activity.id,
      startdate: DateTime.now().add(const Duration(days: 1)),
      enddate: DateTime.now().add(const Duration(days: 1, hours: 1)),
    ),
  ];
}

void main() {
  testWidgets('activity view hydrates the summary from full iCMS details', (
    tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => UserProvider(),
        child: MaterialApp(
          locale: const Locale('fi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ActivityView(
            Activity(id: 820, name: 'Liikuntakerho tiistaisin'),
            _DetailsProvider(),
            app_images.ImageProvider(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Kerhossa liikutaan monipuolisesti'),
      findsOneWidget,
    );
    expect(find.text('Ajankohdat'), findsOneWidget);
  });

  testWidgets('metadata accepts the flat activity record returned by iCMS', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fi'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: MetaSection({
              'address': 'Patteristontie 12',
              'city': 'Liperi',
              'agemin': '10',
              'agemax': '12',
              'registeredvisitorcount': '1',
              'maxvisitors': '16',
              'price': '0.00',
              'organizer': {'name': 'Harrastamisen Liperin malli'},
              'contactinfo': '<p>Harrastekoordinaattori: Ria Raippa</p>',
            }),
          ),
        ),
      ),
    );
    expect(find.text('Patteristontie 12, Liperi'), findsOneWidget);
    expect(find.text('10–12'), findsOneWidget);
    expect(find.text('1 / 16'), findsOneWidget);
    expect(find.text('Maksuton'), findsOneWidget);
    expect(find.text('Harrastamisen Liperin malli'), findsOneWidget);
    expect(find.textContaining('Harrastekoordinaattori'), findsWidgets);
  });
}
