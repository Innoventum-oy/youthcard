import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:youth_card/l10n/app_localizations.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/util/brand.dart';
import 'package:youth_card/src/views/card.dart';
import 'package:youth_card/src/views/userform.dart';

const _profileRecord = <String, dynamic>{
  'id': '7',
  'firstname': 'Demo',
  'lastname': 'User',
  'email': 'demo@example.com',
  'accesslevel': '20',
};

class _ProfileProvider extends UserProvider {
  _ProfileProvider() {
    setUserSilent(User.fromJson(_profileRecord));
  }

  @override
  Future<dynamic> getObject(int userId, dynamic user) async => {
    'data': [_profileRecord],
  };

  @override
  Future<dynamic> getFields(int userId, dynamic user) async => {
    'status': 'success',
    'fields': {
      'firstname': {'displayname': 'First name', 'type': 'textline'},
      'email': {'displayname': 'Email', 'type': 'textline'},
    },
  };
}

Widget _app(_ProfileProvider provider, Widget home) =>
    ChangeNotifierProvider<UserProvider>.value(
      value: provider,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    );

void main() {
  testWidgets('profile edit opens from the flat iCMS user response', (
    tester,
  ) async {
    final provider = _ProfileProvider();
    await tester.pumpWidget(
      _app(provider, UserForm(targetUser: provider.user)),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('First name'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets('wide My Card keeps the branded card and edit controls', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final provider = _ProfileProvider();
    await tester.pumpWidget(_app(provider, MyCard(user: provider.user)));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(BrandIcon), findsOneWidget);
    expect(find.text('YOUTH CARD'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Return'), findsOneWidget);
    expect(
      tester.getSize(find.byType(ListView).first).width,
      lessThanOrEqualTo(760),
    );

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(UserForm), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });
}
