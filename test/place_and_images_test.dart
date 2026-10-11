import 'package:flutter_test/flutter_test.dart';
import 'package:youth_card/l10n/app_localizations_en.dart';
import 'package:youth_card/l10n/app_localizations_fi.dart';
import 'package:youth_card/src/objects/activity.dart';
import 'package:youth_card/src/objects/activityclass.dart';
import 'package:youth_card/src/objects/webpage.dart';
import 'package:youth_card/src/util/category_cover_images.dart';
import 'package:youth_card/src/util/place_activity_matcher.dart';
import 'package:youth_card/src/views/dashboard.dart';

void main() {
  test('activity parsing keeps category and location type through cache', () {
    final activity = Activity.fromJson({
      'id': '42',
      'name': 'Workshop',
      'activitytype': 'activity',
      'activityclass': {'objecttype': 'activityclass', 'objectid': '12'},
    });
    expect(activity.activityClassId, 12);
    expect(activity.activityType, 'activity');
    final restored = Activity.fromJson(
      Map<String, dynamic>.from(activity.toJson()),
    );
    expect(restored.activityClassId, 12);
    expect(restored.activityType, 'activity');
  });

  test('place match requires the same street address', () {
    final place = Activity(address: 'Koulukuja 2');
    expect(
      PlaceActivityMatcher.matches(place, Activity(address: 'koulukuja 2')),
      isTrue,
    );
    expect(
      PlaceActivityMatcher.matches(
        place,
        Activity(address: 'Liperin koulu, Koulukuja 2'),
      ),
      isTrue,
    );
    expect(
      PlaceActivityMatcher.matches(place, Activity(address: 'Koulukuja 21')),
      isFalse,
    );
  });

  test('category cover ID resolves once to a stable image URL', () async {
    var calls = 0;
    final images = CategoryCoverImages(
      serverName: () async => 'example.org',
      loadClasses: (_) async {
        calls++;
        return [ActivityClass(id: 12, coverpicture: '1235')];
      },
    );
    expect(await images.forCategory(12), 'https://example.org/openimage/1235');
    expect(await images.forCategory(12), 'https://example.org/openimage/1235');
    expect(calls, 1);
    expect(
      await images.forImageId('1235'),
      'https://example.org/openimage/1235',
    );
  });

  test('dashboard greeting follows local time', () {
    final en = AppLocalizationsEn();
    final fi = AppLocalizationsFi();
    expect(dashboardGreetingForHour(en, 9), 'Good morning');
    expect(dashboardGreetingForHour(en, 15), 'Good afternoon');
    expect(dashboardGreetingForHour(en, 20), 'Good evening');
    expect(dashboardGreetingForHour(fi, 15), 'Hyvää iltapäivää');
  });

  test('dashboard uses only valid page thumbnail URLs', () {
    expect(
      dashboardBackgroundUrl(WebPage(data: {
        'thumbnailurl': 'https://nuortenliperi.fi/openimage/123',
      })),
      'https://nuortenliperi.fi/openimage/123',
    );
    expect(dashboardBackgroundUrl(WebPage(data: {'thumbnailurl': ''})), isNull);
    expect(
      dashboardBackgroundUrl(WebPage(data: {'thumbnailurl': '/openimage/123'})),
      isNull,
    );
  });
}
