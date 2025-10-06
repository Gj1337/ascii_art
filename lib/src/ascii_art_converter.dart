import 'dart:typed_data';
import 'package:ascii_art_converter/ascii_art_converter.dart';

import 'package:image/image.dart' as img;

/// Converts images to ASCII art with customizable character sets and color modes.
///
/// Configure once, convert many times.
///
/// Example:
/// ```dart
/// final converter = AsciiConverter(
///   width: 100,
///   charset: CharSet.blocks,
///   colorMode: ColorMode.ansi256,
/// );
///
/// final art = await converter.convert(image1Bytes);
/// print(art)
/// ```
/// Example with stream:
/// ```dart
/// final converter = AsciiConverter();
/// final stream = converter.convertStream(imageBytes);
/// await for (final line in stream) {
///   stdout.write(line); //not print because each line contains \r\n
/// }
/// ```
class AsciiArtConverter {
  /// Most monospace fonts are taller than they are wide,
  /// therefore to maintain proper image proportions
  /// there has to be scale coefficient
  final double charAspectRatio;

  /// Output width in characters.
  /// The height is calculated automatically
  /// to maintain the image's aspect ratio.
  final int width;

  /// Character set ordered from darkest to lightest.
  /// Use predefined sets from [CharSet] or provide a custom string
  final String charset;

  /// Whether to invert brightness (darker areas use denser characters).
  final bool invert;

  /// Color output mode.
  final ColorMode colorMode;

  /// Creates an ASCII converter with specified settings.
  const AsciiArtConverter({
    this.width = 80,
    this.charset = CharSet.standart,
    this.invert = false,
    this.colorMode = ColorMode.grayscale,
    this.charAspectRatio = 0.5,
  });

  /// Converts image bytes to ASCII art.
  ///
  /// Returns the complete ASCII art string.
  /// For more flexible approach use [convertStream]
  ///
  /// Throws [FormatException] if image cannot be decoded.
  Future<String> convert(Uint8List imageBytes) async {
    final buffer = StringBuffer();
    final lineStream = convertStream(imageBytes);

    await lineStream.forEach(buffer.write);

    return buffer.toString();
  }

  /// Converts image bytes to ASCII art as a stream of lines.
  ///
  /// Each line includes newline and color codes.
  ///
  /// Returns a [Stream] of strings, where each string represents one line
  /// of ASCII art (including the newline character and any color codes).
  ///
  /// Throws [FormatException] if image cannot be decoded.
  Stream<String> convertStream(Uint8List imageBytes) async* {
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

  /// Creates a copy with some fields replaced.
  ///
  /// Example:
  /// ```dart
  /// final baseConverter = AsciiConverter(width: 100);
  /// final colorConverter = baseConverter.copyWith(colorMode: ColorMode.ansi256);
  /// ```
  AsciiArtConverter copyWith({
    int? width,
    String? charset,
    bool? invert,
    ColorMode? colorMode,
    double? charAspectRatio,
  }) =>
      AsciiArtConverter(
        width: width ?? this.width,
        charset: charset ?? this.charset,
        invert: invert ?? this.invert,
        colorMode: colorMode ?? this.colorMode,
        charAspectRatio: charAspectRatio ?? this.charAspectRatio,
      );

  img.Image _decodeImage(Uint8List bytes) {
    final image = img.decodeImage(bytes);
    if (image == null) {
      throw const FormatException('Unable to decode image data');
    }

    return image;
  }

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

  String _getAnsi256Color(img.Color pixel) {
    final r = (pixel.r * 5 / 255).round();
    final g = (pixel.g * 5 / 255).round();
    final b = (pixel.b * 5 / 255).round();
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
