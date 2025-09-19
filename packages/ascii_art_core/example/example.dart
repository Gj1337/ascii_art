import 'dart:io';
import 'dart:typed_data';
import 'package:ascii_art_core/ascii_art_core.dart';

void main() {
  print('🎨 ASCII Art Converter Example\r\n');
  final imagePath = pickImage();
  if (imagePath == null) return;
  final charSets = pickCharSets();
  final width = pickWidth();

  try {
    for (final charSet in charSets) {
      final converter = AsciiConverter();

      print('Char set $charSet \r\n');
      final pixelArt = converter.convert(
        imagePath,
        width: width,
        charset: charSet,
        colorMode: ColorMode.ansi256,
      );

      print(pixelArt);
    }
  } catch (e) {
    print('❌ Error: $e');
  }
}

Uint8List? pickImage() {
  stdout.write('Enter image path: ');
  final imagePath = stdin.readLineSync()?.trim();

  if (imagePath == null || imagePath.isEmpty) {
    print('❌ No image path provided');
    return null;
  }

  final file = File(imagePath);
  if (!file.existsSync()) {
    throw FileSystemException('Image file not found', imagePath);
  }
  final bytes = file.readAsBytesSync();

  return bytes;
}

int pickWidth() {
  final defaultWidth = AsciiConverter.defaultWidth;

  stdout.write('Enter width (default $defaultWidth): ');
  final widthInput = stdin.readLineSync();
  final width = int.tryParse(widthInput ?? '') ?? defaultWidth;

  return width;
}

List<String> pickCharSets() {
  print('Choose character set (default: all charsets):');

  final charSets = [
    (name: 'standard', value: CharSet.standart),
    (name: 'blocks', value: CharSet.blocks),
    (name: 'simple', value: CharSet.simple),
    (name: 'binary', value: CharSet.binary),
    (name: 'highContrast', value: CharSet.highContrast),
    (name: 'shadedBlocks', value: CharSet.shadedBlocks),
    (name: 'braille', value: CharSet.braille),
    (name: 'geometric', value: CharSet.geometric),
    (name: 'mathematical', value: CharSet.mathematical),
    (name: 'linear', value: CharSet.linear),
    (name: 'organic', value: CharSet.organic),
    (name: 'triangular', value: CharSet.triangular),
    (name: 'diamond', value: CharSet.diamond),
    (name: 'extendedAscii', value: CharSet.extendedAscii),
    (name: 'density', value: CharSet.density),
    (name: 'typewriter', value: CharSet.typewriter),
    (name: 'rounded', value: CharSet.rounded),
    (name: 'squared', value: CharSet.squared),
    (name: 'diagonal', value: CharSet.diagonal),
    (name: 'stars', value: CharSet.stars),
    (name: 'circuit', value: CharSet.circuit),
    (name: 'minimal', value: CharSet.minimal),
    (name: 'texture', value: CharSet.texture),
  ];

  for (var i = 0; i < charSets.length; i++) {
    print('${i + 1}. ${charSets[i].name} - ${charSets[i].value}');
  }

  stdout.write(
      'Enter your choice (1-${charSets.length}, or press Enter for all): ');
  final input = stdin.readLineSync();

  final choice = int.tryParse(input ?? '');
  final validChoise =
      choice != null && choice >= 1 && choice <= charSets.length;

  return validChoise
      ? [charSets[choice - 1].value]
      : charSets.map((charset) => charset.value).toList();
}
