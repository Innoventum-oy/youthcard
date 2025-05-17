
abstract class FileStorageInterface {
  Future<bool> write(dynamic data, String filename);
  Future<dynamic> read(String filename, {int expiration = 0});
  Future<void> clear();
  Future<void> delete(String filename);

}