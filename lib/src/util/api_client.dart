import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:youth_card/src/util/app_url.dart';
import 'package:youth_card/src/objects/activity.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/providers/user_provider.dart';

class ApiClient {
  static final _client = ApiClient._internal();
  final _http = HttpClient();

  ApiClient._internal();

  final String baseUrl = AppUrl.baseURL;

  factory ApiClient() => _client;

  Future<dynamic> _getJson(Uri uri) async {
    User user;
    var response = await (await _http.getUrl(uri)).close();
    var transformedResponse = await response.transform(utf8.decoder).join();
    return json.decode(transformedResponse);
  }
  /*
  Future<String> getResponse({Map params})
  {
    String objecttype = params.objecttype;
    var url = Uri.https(baseUrl, '/$objecttype/',
        { 'page': page.toString()});

    return _getJson(url).then((json) => json['data'])
  }

   */
  //todo: add user token
  Future<List<Activity>> fetchActivities(Map params) async {
    var url = Uri.https(baseUrl, 'api/activity/',
        params);

    return _getJson(url).then((json) => json['data']).then((data) => data
        .toList());
  }
 /*
  Future<List<MediaItem>> getSimilarMedia(int mediaId,
      {String type: "movie"}) async {
    var url = Uri.https(baseUrl, '3/$type/$mediaId/similar', {
      'api_key': API_KEY,
    });

    return _getJson(url).then((json) => json['results']).then((data) => data
        .map<MediaItem>((item) => MediaItem(
        item, (type == "movie") ? MediaType.movie : MediaType.show))
        .toList());
  }

  Future<List<MediaItem>> getMoviesForActor(int actorId) async {
    var url = Uri.https(baseUrl, '3/discover/movie', {
      'api_key': API_KEY,
      'with_cast': actorId.toString(),
      'sort_by': 'popularity.desc'
    });

    return _getJson(url).then((json) => json['results']).then((data) => data
        .map<MediaItem>((item) => MediaItem(item, MediaType.movie))
        .toList());
  }

  Future<List<MediaItem>> getShowsForActor(int actorId) async {
    var url = Uri.https(baseUrl, '3/person/$actorId/tv_credits', {
      'api_key': API_KEY,
    });

    return _getJson(url).then((json) => json['cast']).then((data) => data
        .map<MediaItem>((item) => MediaItem(item, MediaType.show))
        .toList());
  }

  Future<List<Actor>> getMediaCredits(int mediaId,
      {String type: "movie"}) async {
    var url =
    Uri.https(baseUrl, '3/$type/$mediaId/credits', {'api_key': API_KEY});

    return _getJson(url).then((json) =>
        json['cast'].map<Actor>((item) => Actor.fromJson(item)).toList());
  }

  Future<dynamic> getMediaDetails(int mediaId, {String type: "movie"}) async {
    var url = Uri.https(baseUrl, '3/$type/$mediaId', {'api_key': API_KEY});

    return _getJson(url);
  }

  Future<List<TvSeason>> getShowSeasons(int showId) async {
    var detailJson = await getMediaDetails(showId, type: 'tv');
    return detailJson['seasons']
        .map<TvSeason>((item) => TvSeason.fromMap(item))
        .toList();
  }

  Future<List<SearchResult>> getSearchResults(String query) {
    var url = Uri
        .https(baseUrl, '3/search/multi', {'api_key': API_KEY, 'query': query});

    return _getJson(url).then((json) => json['results']
        .map<SearchResult>((item) => SearchResult.fromJson(item))
        .toList());
  }

  Future<List<MediaItem>> fetchShows(
      {int page: 1, String category: "popular"}) async {
    var url = Uri.https(baseUrl, '3/tv/$category',
        {'api_key': API_KEY, 'page': page.toString()});

    return _getJson(url).then((json) => json['results']).then((data) => data
        .map<MediaItem>((item) => MediaItem(item, MediaType.show))
        .toList());
  }

  Future<List<Episode>> fetchEpisodes(int showId, int seasonNumber) {
    var url = Uri.https(baseUrl, '3/tv/$showId/season/$seasonNumber', {
      'api_key': API_KEY,
    });

    return _getJson(url).then((json) => json['episodes']).then(
            (data) => data.map<Episode>((item) => Episode.fromJson(item)).toList());
  }

  */
}
