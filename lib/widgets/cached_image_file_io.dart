import 'package:flutter/material.dart';

import '../core/utils/image_sync_codec.dart';
import '../core/utils/picked_image_storage.dart';

/// Local file, data URI, or remote URL image with a simple memory cache.
class CachedImageFile extends StatefulWidget {
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
  State<CachedImageFile> createState() => _CachedImageFileState();
}

class _CachedImageFileState extends State<CachedImageFile> {
  static final Map<String, ImageProvider> _cache = {};
  ImageProvider? _imageProvider;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(CachedImageFile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filePath != widget.filePath) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    final path = widget.filePath.trim();
    if (path.isEmpty) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      return;
    }

    if (_cache.containsKey(path)) {
      _imageProvider = _cache[path];
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = false;
      });
      return;
    }

    if (isDataImagePath(path) || isRemoteImagePath(path)) {
      final provider = imageProviderForPath(path);
      if (provider == null) {
        if (!mounted) return;
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
        return;
      }
      _cache[path] = provider;
      _imageProvider = provider;
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = false;
      });
      return;
    }

    final provider = imageProviderForPath(path);
    if (provider == null) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      return;
    }

    _cache[path] = provider;
    _imageProvider = provider;
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _hasError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return widget.errorWidget ?? _defaultFallback();
    }

    if (_isLoading || _imageProvider == null) {
      return widget.placeholder ?? _defaultLoading();
    }

    Widget image = Image(
      image: _imageProvider!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) {
        return widget.errorWidget ?? _defaultFallback();
      },
    );

    if (widget.borderRadius != null) {
      image = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: image,
      );
    }

    return image;
  }

  Widget _defaultFallback() {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: const Icon(Icons.person, color: Colors.grey),
    );
  }

  Widget _defaultLoading() {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}
