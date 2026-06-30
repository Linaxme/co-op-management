import '../utils/image_sync_codec.dart';

class OrganizationImageStorage {
  Future<String?> uploadLogo({
    required String coopId,
    required String? path,
  }) =>
      encodeLocalImageForSync(path);

  Future<String?> uploadSignature({
    required String coopId,
    required String? path,
  }) =>
      encodeLocalImageForSync(path);
}
