import 'package:flutter/material.dart';

import '../core/utils/image_sync_codec.dart';
import '../core/utils/picked_image_storage.dart';

/// Web: data URI and remote URLs; local device paths are unavailable.
class CachedImageFile extends StatelessWidget {
  final String filePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const CachedImageFile({
    super.key,
    required this.filePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final path = filePath.trim();
    if (path.isEmpty ||
        (!isRemoteImagePath(path) && !isDataImagePath(path))) {
      return errorWidget ??
          SizedBox(
            width: width,
            height: height,
            child: const Icon(Icons.person, color: Colors.grey),
          );
    }

    if (isDataImagePath(path)) {
      final provider = imageProviderForPath(path);
      if (provider == null) {
        return errorWidget ?? _fallback();
      }
      Widget image = Image(
        image: provider,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => errorWidget ?? _fallback(),
      );
      if (borderRadius != null) {
        image = ClipRRect(borderRadius: borderRadius!, child: image);
      }
      return image;
    }

    Widget image = Image.network(
      path,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return placeholder ??
            SizedBox(
              width: width,
              height: height,
              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? _fallback();
      },
    );

    if (borderRadius != null) {
      image = ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }

  Widget _fallback() {
    return SizedBox(
      width: width,
      height: height,
      child: const Icon(Icons.person, color: Colors.grey),
    );
  }
}
