import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:youth_card/src/util/app_url.dart';
import 'package:youth_card/src/objects/activity.dart';
import 'package:youth_card/src/objects/user.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/util/utils.dart';
class ApiClient {
  static final _client = ApiClient._internal();
  final _http = HttpClient();
  ApiClient._internal();

  final String baseUrl = AppUrl.baseURL;

  factory ApiClient() => _client;

  Future<dynamic> _getJson(Uri uri) async {

    var response = await http.get(uri);
    print(response.statusCode);
    if(response.statusCode==200) {
      if(response.body.isNotEmpty) {
        print(response.body);
        Map<String, dynamic> body = json.decode(response.body);
      /*  print('GETJSON DATA RECEIVED:');
        body.forEach((key, value) {
          if (key != 'data') print('$key = $value');
        });
        print('END GETJSON');
        */

        return (body);
      }
      else {
        print('response body was empty.');
        return false;
      }
    }
    else return false;

  }

    Future<Map<String, dynamic>> getConfirmationKey(String email) async {
     // print( 'requesting getverificationcode for '+email);
      final Map<String, dynamic> params = {
        'method' : 'json',
        'action': 'getverificationcode',
        'email': email
      };
    var url = Uri.https(AppUrl.baseURL, AppUrl.requestValidationToken,params);
  //   var response = _getJson(url) as Map<String, dynamic>;
      return _getJson(url).then((json){
        return json;
      });
  }
  Future<Map<String, dynamic>> sendConfirmationKey({contact,code,userid}) async {
    final Map<String, dynamic> params = {
      'method' : 'json',
      'action': 'verify',
      'field': contact,
      'contactmethodid': contact,
      'userid' : userid,
      'code': code
    };

    var url = Uri.https(AppUrl.baseURL, AppUrl.checkValidationToken,params);
    //   var response = _getJson(url) as Map<String, dynamic>;

    return _getJson(url).then((json){
     // print(json);
      return json;
    });
  }

  Future<Map<String, dynamic>> changePassword({password,userid,singlepass}) async {


    final Map<String, dynamic> params = {
      'method' : 'json',
      'action': 'setpassword',
      'singlepass':singlepass,
      'userid' : userid,
      'password': password,
      'verification' : password
    };
   //params.forEach((key, value) {print('$key = $value');});
    var url = Uri.https(AppUrl.baseURL, AppUrl.checkValidationToken,params);
    //   var response = _getJson(url) as Map<String, dynamic>;

    return _getJson(url).then((json){
    //  print(json);
      return json;

    });

  }
  Future<List<Activity>> loadActivities(Map<String,dynamic> params) async {
    //debug: print params
    params.forEach((key, value) {print('$key = $value');});
    var url = Uri.https(baseUrl, 'api/activity/',
        params);
    return _getJson(url).then((json) => json['data']).then((data) {
      //print(data);
      return data
        .map<Activity>((data) => Activity.fromJson(data))
        .toList();
      });

  }

  Future<dynamic> getActivityDetails(int activityId, User user) async {

    var url = Uri.https(baseUrl, 'api/activity/$activityId', { 'api-key': user.token,'api_key':user.token});

    return _getJson(url).then((json) => json['data']).then((data) {
       // print(data);
        return data;
      });

  }

  Future<dynamic> getImageDetails(int imageId, User user) async {
    var url = Uri.https(baseUrl, 'api/image/$imageId', { 'api-key': user.token,'api_key':user.token});

    return _getJson(url);
  }
  Future<void> registerForActivity(activityId,User user) async{

    return updateActivityRegistration(activityId:activityId,user:user);
  }
  Future<dynamic> updateActivityRegistration({int? activityId, String visitStatus='registered',required User user}) async
  {
    Map map;
/* todo - positioning
    if(_currentPosition == null){
      Notify('Current position unknown, returning false from sendData. How to get the position first instead?');
      return "Error";
    }

    if(user== null){
      Notify('user is not set for updating registration, returning false. Why is user not set?');
      print(user);
      return "error";
    }
*/
    Map<String, String> params = {
      'action': 'recordvisit',
      'activityid': activityId!.toString(),
      'userid': user.id.toString(),
      'visitstatus': visitStatus,
      'api-key': user.token!,
      'api_key': user.token!
      //'latitude': _latitude.toString(),
      //  'longitude':  _longitude.toString()

    };

    var url = Uri.https(AppUrl.baseURL, '/api/dispatcher/activity/', params);
    var response = _getJson(url) as Map<String, dynamic>;

    if (response['message'].isNotEmpty)
      Notify(response['message']);
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
