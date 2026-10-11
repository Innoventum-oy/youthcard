import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:youth_card/l10n/app_localizations.dart';
import 'package:youth_card/src/objects/activity.dart';
import 'package:youth_card/src/providers/activity_list_provider.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/views/calendar.dart';

class _EmptyActivities extends ActivityListProvider {
  @override
  Future<List<Activity>> loadItems(
    dynamic params, {
    bool refresh = false,
  }) async => [];
}

class _PagedActivities extends ActivityListProvider {
  final offsets = <String>[];

  @override
  Future<List<Activity>> loadItems(
    dynamic params, {
    bool refresh = false,
  }) async {
    offsets.add(params['offset'] as String);
    final date = DateTime.now().add(const Duration(days: 1));
    if (params['offset'] == '0') {
      return List.generate(
        250,
        (index) =>
            Activity(id: index, name: 'Event $index', nexteventdate: date),
      );
    }
    return [Activity(id: 250, name: 'Event 250', nexteventdate: date)];
  }
}

void main() {
  testWidgets('calendar weekdays follow the Finnish app locale', (
    tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider<ActivityListProvider>(
            create: (_) => _EmptyActivities(),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('fi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ActivityCalendar(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ma'), findsOneWidget);
    expect(find.text('Mon'), findsNothing);
  });

  testWidgets('calendar loads subsequent pages', (tester) async {
    final provider = _PagedActivities();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider<ActivityListProvider>.value(value: provider),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ActivityCalendar(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(provider.offsets, ['0', '250']);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });
}
