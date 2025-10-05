import 'dart:typed_data';
import 'package:ascii_art/ascii_art.dart';
import 'package:image/image.dart' as img;

/// Converts images to ASCII art with customizable character sets and color modes.
///
/// Example:
/// ```dart
/// final converter = AsciiConverter();
/// final asciiArt = await converter.convert(
///   imageBytes,
///   width: 100,
///   charset: CharSet.blocks,
///   colorMode: ColorMode.ansi256,
/// );
/// print(asciiArt);
/// ```
/// Example with stream:
/// ```dart
/// final converter = AsciiConverter();
/// final stream = converter.convertStream(imageBytes, width: 80);
/// await for (final line in stream) {
///   stdout.write(line);
/// }
/// ```
class AsciiConverter {
  /// Default character aspect ratio for monospace fonts.
  ///
  /// Most monospace fonts are approximately 2x taller than they are wide,
  /// so the default ratio is 0.5 to maintain proper image proportions.
  static const defaultCharAspectRatio = 0.5;

  /// Default output width in characters.
  ///
  /// Set to 80 characters, which fits most terminal windows comfortably.
  static const defaultWidth = 80;

  /// Default character set for conversion.
  ///
  /// Uses [CharSet.standart] which provides good detail and contrast.
  static const defaultCharset = CharSet.standart;

  /// Default invert setting.
  ///
  /// When true, darker image areas use denser characters. This typically
  /// produces more natural-looking results for most images.
  static const defaultInvert = true;

  /// Default color mode for conversion.
  ///
  /// Uses [ColorMode.grayscale] for maximum compatibility.
  static const defaultColorMode = ColorMode.grayscale;

  // ignore: public_member_api_docs
  AsciiConverter();

  /// Converts image bytes into ASCII art as a complete string.
  ///
  /// Parameters:
  /// - [imageBytes]: The raw bytes of the image to convert. Supports common
  ///   formats like PNG, JPEG, GIF, BMP, etc.
  /// - [width]: Output width in characters. The height is calculated automatically
  ///   to maintain the image's aspect ratio. Default value is [defaultWidth].
  /// - [charset]: String of characters ordered from darkest to lightest.
  ///   Use predefined sets from [CharSet] or provide a custom string
  ///   where symbols are ordered from darker to lighter.
  ///   Default value is [defaultCharset].
  /// - [invert]: If true, darker areas use denser characters.
  ///   Suitable for black-white pictures.
  /// - [colorMode]: Determines how colors are represented. See [ColorMode]
  ///   for available options. Default value is [defaultColorMode]
  /// - [charAspectRatio]: Ratio to adjust for character dimensions. Use 0.5
  ///   for typical monospace fonts (characters are twice as tall as wide).
  ///
  /// Throws [FormatException] if the image data cannot be decoded.
  ///
  /// For more flexible control, consider using [convertStream] instead.
  Future<String> convert(
    Uint8List imageBytes, {
    int width = defaultWidth,
    String charset = defaultCharset,
    bool invert = defaultInvert,
    ColorMode colorMode = defaultColorMode,
    double charAspectRatio = defaultCharAspectRatio,
  }) async {
    final buffer = StringBuffer();
    final lineStream = convertStream(
      imageBytes,
      width: width,
      charset: charset,
      invert: invert,
      colorMode: colorMode,
      charAspectRatio: charAspectRatio,
    );

    await lineStream.forEach(buffer.write);

    return buffer.toString();
  }

  /// Converts image bytes into ASCII art as a stream of lines.
  ///
  /// Parameters:
  /// - [imageBytes]: The raw bytes of the image to convert. Supports common
  ///   formats like PNG, JPEG, GIF, BMP, etc.
  /// - [width]: Output width in characters. The height is calculated automatically
  ///   to maintain the image's aspect ratio. Default value is [defaultWidth].
  /// - [charset]: String of characters ordered from darkest to lightest.
  ///   Use predefined sets from [CharSet] or provide a custom string
  ///   where symbols are ordered from darker to lighter.
  ///   Default value is [defaultCharset].
  /// - [invert]: If true, darker areas use denser characters.
  ///   Suitable for black-white pictures.
  /// - [colorMode]: Determines how colors are represented. See [ColorMode]
  ///   for available options. Default value is [defaultColorMode]
  /// - [charAspectRatio]: Ratio to adjust for character dimensions. Use 0.5
  ///   for typical monospace fonts (characters are twice as tall as wide).
  ///
  /// Returns a [Stream] of strings, where each string represents one line
  /// of ASCII art (including the newline character and any color codes).
  ///
  /// Throws [FormatException] if the image data cannot be decoded.
  Stream<String> convertStream(
    Uint8List imageBytes, {
    int width = defaultWidth,
    String charset = defaultCharset,
    bool invert = defaultInvert,
    ColorMode colorMode = defaultColorMode,
    double charAspectRatio = defaultCharAspectRatio,
  }) async* {
    final image = _decodeImage(imageBytes);
    final resized = _resizeImage(image, width, charAspectRatio);

    final resetCode = _getResetCode(colorMode);

    for (var y = 0; y < resized.height; y++) {
      final buffer = StringBuffer();

      for (var x = 0; x < resized.width; x++) {
        final pixel = resized.getPixel(x, y);
        final brightness = img.getLuminance(pixel);
        final char = _mapBrightnessToChar(brightness.toInt(), charset, invert);
        final colorCode = _getColorCode(pixel, colorMode);

        buffer.write('$colorCode$char');
      }
      buffer.write('$resetCode\r\n');

      yield buffer.toString();
    }
  }

  img.Image _decodeImage(Uint8List bytes) {
    final image = img.decodeImage(bytes);
    if (image == null) {
      throw const FormatException('Unable to decode image data');
    }

    return image;
  }

  /// Resizes image maintaining aspect ratio, adjusted for character dimensions
  img.Image _resizeImage(img.Image image, int width, double charAspectRatio) {
    final aspectRatio = image.height / image.width;
    final targetHeight = (width * aspectRatio * charAspectRatio).round();

    return img.copyResize(image, width: width, height: targetHeight);
  }

  String _mapBrightnessToChar(int brightness, String charset, bool invert) {
    final targetBrightness = invert ? 255 - brightness : brightness;
    final index = (targetBrightness * (charset.length - 1)) ~/ 255;

    return charset[index.clamp(0, charset.length - 1)];
  }

  String _getColorCode(img.Color pixel, ColorMode colorMode) =>
      switch (colorMode) {
        ColorMode.grayscale => '',
        ColorMode.ansi256 => _getAnsi256Color(pixel),
        ColorMode.trueColor => _getTrueColor(pixel)
      };

  String _getResetCode(ColorMode colorMode) =>
      colorMode == ColorMode.grayscale ? '' : '\x1b[0m';

  /// Maps RGB to ANSI 256-color using 6x6x6 color cube
  String _getAnsi256Color(img.Color pixel) {
    final r = (pixel.r.toInt() * 5 / 255).round();
    final g = (pixel.g.toInt() * 5 / 255).round();
    final b = (pixel.b.toInt() * 5 / 255).round();
    final color = 16 + 36 * r + 6 * g + b;

    return '\x1b[38;5;${color}m';
  }

  String _getTrueColor(img.Color pixel) {
    final r = pixel.r.toInt();
    final g = pixel.g.toInt();
    final b = pixel.b.toInt();

    return '\x1b[38;2;$r;$g;${b}m';
  }
}
