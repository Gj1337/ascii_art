import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:ascii_art/ascii_art.dart';
import 'package:image/image.dart' as img;

void main() {
  group('AsciiArtConverter', () {
    group('Convert image', () {
      test('Convert png image by convert method', () async {
        final image = _createSolidColorImage(100, 100, r: 85, g: 170, b: 255);
        final bytes = Uint8List.fromList(img.encodePng(image));

        final result = await const AsciiArtConverter(width: 5).convert(
          bytes,
        );

        expect(result, isNotEmpty);
        expect(result.split('\r\n').length, greaterThan(0));
      });

      test('Convert png image by stream method', () async {
        final image = _createSolidColorImage(100, 100, r: 85, g: 170, b: 255);
        final bytes = Uint8List.fromList(img.encodePng(image));

        await const AsciiArtConverter(width: 5).convertStream(bytes).forEach(
          (line) {
            expect(line, isNotEmpty);
            expect(line, endsWith('\r\n'));
          },
        );
      });
    });

    group(
      'Brightness to Character Mapping',
      () {
        const charSet = '1234567890';
        test('Map darkest pixel', () async {
          final image = _createSolidColorImage(1, 1, r: 0, g: 0, b: 0);
          final bytes = Uint8List.fromList(img.encodePng(image));

          final result = await const AsciiArtConverter(
            width: 1,
            charset: charSet,
            invert: false,
          ).convert(bytes);

          expect(result.trim(), equals(charSet[0]));

          final resultInverted = await const AsciiArtConverter(
            width: 1,
            charset: charSet,
            invert: true,
          ).convert(
            bytes,
          );

          expect(resultInverted.trim(), equals(charSet[charSet.length - 1]));
        });

        test('Map brightest pixel', () async {
          final image = _createSolidColorImage(1, 1, r: 255, g: 255, b: 255);
          final bytes = Uint8List.fromList(img.encodePng(image));

          final result = await const AsciiArtConverter(
            width: 1,
            charset: charSet,
            invert: false,
          ).convert(
            bytes,
          );

          expect(result.trim(), equals(charSet[charSet.length - 1]));

          final resultInverted = await const AsciiArtConverter(
            width: 1,
            charset: charSet,
            invert: true,
          ).convert(
            bytes,
          );

          expect(resultInverted.trim(), equals(charSet[0]));
        });

        test(
          'Check gradient mapping',
          () async {
            const imageWidth = 256;
            const imageHeight = 1;
            final gradientImage =
                img.Image(width: imageWidth, height: imageHeight);
            for (var i = 0; i <= imageWidth - 1; i++) {
              gradientImage.setPixelRgb(i, imageHeight - 1, i, i, i);
            }
            final gradientBytes =
                Uint8List.fromList(img.encodePng(gradientImage));

            final result = await const AsciiArtConverter(
              width: imageWidth,
              charset: charSet,
              invert: false,
            ).convert(
              gradientBytes,
            );

            expect(result, matches(RegExp('[$charSet\\s]')));

            final resultInverted = await const AsciiArtConverter(
              width: imageWidth,
              charset: charSet,
              invert: true,
            ).convert(
              gradientBytes,
            );

            expect(
              resultInverted,
              matches(RegExp('[${charSet.split('').reversed.join()}\\s]')),
            );
          },
        );
      },
    );

    group('Image Resizing', () {
      test('Resize image to specified width', () async {
        final image = _createSolidColorImage(100, 100, r: 85, g: 170, b: 255);
        final bytes = Uint8List.fromList(img.encodePng(image));

        final result = await const AsciiArtConverter(width: 10).convert(bytes);
        final lines = result.split('\r\n').where((l) => l.isNotEmpty).toList();

        expect(lines.first.length, equals(10));
      });

      test('should maintain aspect ratio with character adjustment', () async {
        final image = _createSolidColorImage(100, 100, r: 85, g: 170, b: 255);
        final bytes = Uint8List.fromList(img.encodePng(image));
        const width = 20;
        const charAspectRatio = 0.5;

        final result = await const AsciiArtConverter(
          width: width,
          charAspectRatio: charAspectRatio,
        ).convert(
          bytes,
        );
        final lines = result.split('\r\n').where((l) => l.isNotEmpty).toList();
        final expectedHeight = (width * charAspectRatio).round();

        expect(lines.length, equals(expectedHeight));
      });

      test('Handle different aspect ratios', () async {
        final image = _createSolidColorImage(200, 100, r: 85, g: 170, b: 255);
        final bytes = Uint8List.fromList(img.encodePng(image));
        const width = 20;

        final result = await const AsciiArtConverter(
          width: width,
        ).convert(bytes);
        final lines = result.split('\r\n').where((l) => l.isNotEmpty).toList();

        expect(lines.length, lessThan(width));
      });
    });

    group('Color Modes', () {
      test('Grayscale mode', () async {
        final image = _createSolidColorImage(2, 2, r: 255, g: 0, b: 0);
        final bytes = Uint8List.fromList(img.encodePng(image));

        final result = await const AsciiArtConverter(
          width: 2,
          colorMode: ColorMode.grayscale,
        ).convert(
          bytes,
        );

        expect(result, isNot(contains('\x1b[')));
      });

      test('ANSI256 color codes', () async {
        final image = _createSolidColorImage(2, 2, r: 255, g: 0, b: 0);
        final bytes = Uint8List.fromList(img.encodePng(image));

        final result = await const AsciiArtConverter(
          width: 2,
          colorMode: ColorMode.ansi256,
        ).convert(
          bytes,
        );

        expect(result, contains('\x1b[38;5;196m'));
        expect(result, contains('\x1b[0m'));
      });

      test('TrueColor codes', () async {
        final (r, g, b) = (128, 64, 32);
        final image = _createSolidColorImage(2, 2, r: 128, g: 64, b: 32);
        final bytes = Uint8List.fromList(img.encodePng(image));

        final result = await const AsciiArtConverter(
          width: 2,
          colorMode: ColorMode.trueColor,
        ).convert(
          bytes,
        );

        expect(result, contains('\x1b[38;2;$r;$g;${b}m'));
        expect(result, contains('\x1b[0m'));
      });

      test('Include reset codes at end of each line with color', () async {
        final image = _createSolidColorImage(100, 100, r: 85, g: 170, b: 255);
        final bytes = Uint8List.fromList(img.encodePng(image));

        final result = await const AsciiArtConverter(
                width: 3, colorMode: ColorMode.ansi256)
            .convert(
          bytes,
        );
        final lines = result.split('\r\n').where((l) => l.isNotEmpty).toList();

        for (final line in lines) {
          expect(line, contains('\x1b[0m'));
        }
      });
    });
  });
}

img.Image _createSolidColorImage(
  int width,
  int height, {
  required int r,
  required int g,
  required int b,
}) {
  final image = img.Image(width: width, height: height);

  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      image.setPixelRgba(x, y, r, g, b, 255);
    }
  }

  return image;
}
