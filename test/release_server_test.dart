import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youth_card/src/util/app_url.dart';
import 'package:youth_card/src/util/shared_preference.dart';

void main() {
  test('release settings ignore an older server selection and key', () async {
    SharedPreferences.setMockInitialValues({
      'server': 'nuortenjoensuu.fi',
      'servername': 'Nuortenjoensuu',
      'anonymousapikey': 'old-key',
    });

    final release = Settings(releaseMode: true);
    expect(await release.getServer(), AppUrl.productionServerHost);
    expect(await release.getServerName(), AppUrl.productionServerName);
    expect(await release.isServerSelected(), isTrue);
    expect(
      await release.getValue('anonymousapikey'),
      AppUrl.anonymousApikeys[AppUrl.productionServerName],
    );

    final debug = Settings(releaseMode: false);
    expect(await debug.getServer(), 'nuortenjoensuu.fi');
    expect(await debug.getServerName(), 'Nuortenjoensuu');
    expect(await debug.getValue('anonymousapikey'), 'old-key');
  });
}
