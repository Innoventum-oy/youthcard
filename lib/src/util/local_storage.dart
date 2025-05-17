// lib/src/util/local_storage.dart
import 'package:youth_card/src/util/file_storage_interface.dart';
// Conditional imports for platform-specific implementations
import 'package:youth_card/src/util/file_storage_web.dart' if (dart.library.io) 'package:youth_card/src/util/file_storage_mobile.dart' as platform_specific_storage;

// Default implementation for file storage
FileStorageInterface getFileStorage() {
  // This will return an instance of WebFileStorage on web
  // and MobileFileStorage on mobile (or other IO environments)
  return platform_specific_storage.getPlatformFileStorage();
}