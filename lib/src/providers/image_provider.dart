import '../objects/image.dart';
import 'objectprovider.dart';

class ImageProvider extends ObjectProvider {
  ImageProvider();
  final ApiClient _apiClient = ApiClient();
  //ApiClient _apiClient = ApiClient();

  @override
  Future<List<ImageObject>> loadItems(params) async {
    return _apiClient.loadImages(params);
  }

  @override
  Future<dynamic> getDetails(int imageId, user) {
    return _apiClient.getImageDetails(imageId, user);
  }
}