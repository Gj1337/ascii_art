import 'dart:io';
import 'package:ascii_art_core/src/char_set.dart';
import 'package:image/image.dart' as img;

class AsciiConverter {
  /// Characters in most fonts are taller than they are wide,
  /// so ASCII art looks stretched vertically if not corrected.
  /// This factor (~0.5) compensates for that difference.
  static const double charAspectRatio = 0.5;

  /// Default width of ASCII art (in characters).
  static const int defaultWidth = 80;

  /// Default charset for brightness mapping.
  static const String defaultCharset = CharSet.standart;

  /// Whether to invert brightness mapping by default.
  static const bool defaultInvert = true;

  /// Converts an image file at [imagePath] into ASCII art.
  ///
  /// - [width]: target ASCII art width (characters).
  /// - [charset]: set of characters used for brightness mapping.
  /// - [invert]: flips brightness mapping (dark <-> light).
  String convertImage(
    String imagePath, {
    int width = defaultWidth,
    String charset = defaultCharset,
    bool invert = defaultInvert,
  }) {
    final image = _loadImage(imagePath);
    final grayscale = img.grayscale(image);
    final resized = _resizeImage(grayscale, width);
    return _convertToAscii(resized, charset, invert: invert);
  }

  img.Image _loadImage(String imagePath) {
    final file = File(imagePath);

    if (!file.existsSync()) {
      throw FileSystemException('Image file not found', imagePath);
    }

    final bytes = file.readAsBytesSync();
    final image = img.decodeImage(bytes);

    if (image == null) {
      throw FormatException('Unable to decode image: $imagePath');
    }

    return image;
  }

  img.Image _resizeImage(img.Image image, int width) {
    final aspectRatio = image.height / image.width;
    final targetHeight = (width * aspectRatio * charAspectRatio).round();
    return img.copyResize(image, width: width, height: targetHeight);
  }

  String _convertToAscii(
    img.Image image,
    String charset, {
    required bool invert,
  }) {
    final asciiImage = StringBuffer();

    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final brightness = img.getLuminance(pixel);
        final char =
            _mapBrightnessToChar(brightness.toInt(), charset, invert: invert);
        asciiImage.write(char);
      }
      asciiImage.write('\n');
    }

    return asciiImage.toString();
  }

  String _mapBrightnessToChar(int brightness, String charset,
      {required bool invert}) {
    final targetBrightness = invert ? 255 - brightness : brightness;
    final index = (targetBrightness * (charset.length - 1)) ~/ 255;
    return charset[index.clamp(0, charset.length - 1)];
  }
}
