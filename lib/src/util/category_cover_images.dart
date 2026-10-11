import 'package:youth_card/src/objects/activityclass.dart';
import 'package:youth_card/src/providers/activity_class_provider.dart';
import 'package:youth_card/src/util/shared_preference.dart';

/// Resolves category image IDs to stable iCMS /openimage URLs.
class CategoryCoverImages {
  CategoryCoverImages({
    Future<List<ActivityClass>> Function(Map<String, String>)? loadClasses,
    Future<String> Function()? serverName,
    DateTime Function()? clock,
  }) : _loadClasses = loadClasses ?? ActivityClassProvider().loadItems,
       _serverName = serverName ?? Settings().getServer,
       _clock = clock ?? DateTime.now;

  static final shared = CategoryCoverImages();
  static const _lifetime = Duration(minutes: 30);
  static const _pageSize = 100;

  final Future<List<ActivityClass>> Function(Map<String, String>) _loadClasses;
  final Future<String> Function() _serverName;
  final DateTime Function() _clock;
  final _cache = <String, (DateTime, Map<int, String>)>{};
  final _inFlight = <String, Future<Map<int, String>>>{};

  Future<String?> forCategory(int? categoryId, {String? token}) async {
    if (categoryId == null) return null;
    final server = await _serverName();
    final key = '$server:${token ?? ''}';
    final snapshot = _cache[key];
    if (snapshot != null && _clock().isBefore(snapshot.$1)) {
      return snapshot.$2[categoryId];
    }
    final pending = _inFlight.putIfAbsent(key, () => _load(server, token));
    try {
      return (await pending)[categoryId];
    } finally {
      _inFlight.remove(key);
    }
  }

  Future<String?> forImageId(String? imageId) async {
    final id = int.tryParse(imageId ?? '');
    if (id == null) return null;
    return _imageUrl(await _serverName(), id);
  }

  Future<Map<int, String>> _load(String server, String? token) async {
    final covers = <int, String>{};
    for (var page = 0; page < 10; page++) {
      final params = <String, String>{
        'loadmethod': 'loadActivityClassesWithActivities',
        'limit': '$_pageSize',
        'offset': '${page * _pageSize}',
        'sort': 'name',
      };
      if (token != null) params['api_key'] = token;
      final classes = await _loadClasses(params);
      for (final category in classes) {
        final id = category.id;
        if (id == null) continue;
        final direct = category.coverpictureurl;
        final imageId = int.tryParse(category.coverpicture ?? '');
        if (direct != null && direct.isNotEmpty) {
          covers[id] = direct;
        } else if (imageId != null) {
          covers[id] = _imageUrl(server, imageId);
        }
      }
      if (classes.length < _pageSize) break;
    }
    _cache['$server:${token ?? ''}'] = (_clock().add(_lifetime), covers);
    return covers;
  }

  String _imageUrl(String server, int imageId) =>
      Uri.https(server, '/openimage/$imageId').toString();
}
