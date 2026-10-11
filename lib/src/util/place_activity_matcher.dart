import 'package:youth_card/src/objects/activity.dart';

/// Matches a location record to an event's street address.
/// iCMS currently exposes the address but no venue object ID on activities.
class PlaceActivityMatcher {
  static String _normalise(String? value) => (value ?? '')
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9åäö]+'), ' ')
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ');

  static bool matches(Activity place, Activity activity) {
    final placeAddress = _normalise(place.address);
    final activityAddress = _normalise(activity.address);
    if (placeAddress.length < 6 || activityAddress.isEmpty) return false;
    if (placeAddress == activityAddress) return true;
    // Some event addresses prefix the venue name to the street address.
    return RegExp(r'\d').hasMatch(placeAddress) &&
        ' $activityAddress '.contains(' $placeAddress ');
  }

  static List<Activity> atPlace(
    Activity place,
    Iterable<Activity> activities,
  ) => activities.where((activity) => matches(place, activity)).toList();
}
