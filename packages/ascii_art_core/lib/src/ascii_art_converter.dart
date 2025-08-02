import 'dart:io';
import 'package:image/image.dart' as img;

class AsciiConverter {
  static const String defaultCharset = ' .:-=+*#%@';

  /// Converts an image file to ASCII art (pixel-by-pixel)
  /// default [charset] = .:-=+*#%@
  String convertImage(
    String imagePath, {
    int width = 80,
    String charset = defaultCharset,
    bool maintainAspectRatio = true,
  }) {
    final image = _loadImage(imagePath);
    final grayscale = img.grayscale(image);
    final resized = _resizeImage(grayscale, width, maintainAspectRatio);

    return _convertToAscii(resized, charset);
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

  /// Resizes image to target width while maintaining aspect ratio
  img.Image _resizeImage(
      img.Image image, int targetWidth, bool maintainAspectRatio) {
    if (!maintainAspectRatio) {
      return img.copyResize(image, width: targetWidth);
    }

    // Calculate height to maintain aspect ratio
    // Note: ASCII characters are taller than wide, so we adjust
    final aspectRatio = image.height / image.width;
    final targetHeight = (targetWidth * aspectRatio * 0.5)
        .round(); // 0.5 to account for character ratio

    return img.copyResize(image, width: targetWidth, height: targetHeight);
  }

  String _convertToAscii(img.Image image, String charset) {
    final result = <String>[];

    for (int y = 0; y < image.height; y++) {
      final row = StringBuffer();

      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final brightness = img.getLuminance(pixel);
        final char = _mapBrightnessToChar(brightness.toInt(), charset);
        row.write(char);
      }

      result.add(row.toString());
    }

    return result.join('\n');
  }


  String _mapBrightnessToChar(int brightness, String charset) {
    // Invert brightness so dark areas use dense characters
    final invertedBrightness = 255 - brightness;
    final index = (invertedBrightness * (charset.length - 1)) ~/ 255;
    return charset[index.clamp(0, charset.length - 1)];
  }
}
