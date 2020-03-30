part of image_crop;

class ImageOptions {
  final int width;
  final int height;
  final int? orientation;

  ImageOptions({
    required this.width,
    required this.height,
    this.orientation
  });

  @override
  int get hashCode => hashValues(width, height);

  @override
  bool operator ==(other) {
    return other is ImageOptions &&
        other.width == width &&
        other.height == height && other.orientation == orientation;
  }

  @override
  String toString() {
    return '$runtimeType(width: $width, height: $height, orientation: $orientation)';
  }
}

class ImageCrop {
  static const _channel =
      const MethodChannel('plugins.lykhonis.com/image_crop');

  static Future<bool> requestPermissions() => _channel
      .invokeMethod('requestPermissions')
      .then<bool>((result) => result);

  static Future<ImageOptions> getImageOptions({
    required File file,
  }) async {
    final result =
        await _channel.invokeMethod('getImageOptions', {'path': file.path});

    return ImageOptions(
      width: result['width'],
      height: result['height'],
      orientation: result['orientation'],
    );
  }

  static Future<File> cropImage({
    required File file,
    required Rect area,
    double? scale,
  }) =>
      _channel.invokeMethod('cropImage', {
        'path': file.path,
        'left': area.left,
        'top': area.top,
        'right': area.right,
        'bottom': area.bottom,
        'scale': scale ?? 1.0,
      }).then<File>((result) => File(result));

  static Future<File> sampleImage({
    required File file,
    int? preferredSize,
    int? preferredWidth,
    int? preferredHeight,
  }) async {
    assert(() {
      if (preferredSize == null &&
          (preferredWidth == null || preferredHeight == null)) {
        throw ArgumentError(
            'Preferred size or both width and height of a resampled image must be specified.');
      }
      return true;
    }());

    final String path = await _channel.invokeMethod('sampleImage', {
      'path': file.path,
      'maximumWidth': preferredSize ?? preferredWidth,
      'maximumHeight': preferredSize ?? preferredHeight,
    });

    return File(path);
  }
}
