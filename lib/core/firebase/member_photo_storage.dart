import '../utils/image_sync_codec.dart';

class MemberPhotoStorage {
  Future<String?> uploadIfLocal({
    required String coopId,
    required String memberUuid,
    required String? photoPath,
  }) =>
      encodeLocalImageForSync(photoPath);
}
