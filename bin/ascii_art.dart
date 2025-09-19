import 'dart:io';
import 'package:args/args.dart';
import 'package:ascii_art/ascii_art.dart';

const charPresets = <String, String>{
  'standard': CharSet.standart,
  'blocks': CharSet.blocks,
  'simple': CharSet.simple,
  'binary': CharSet.binary,
  'high-contrast': CharSet.highContrast,
  'shaded-blocks': CharSet.shadedBlocks,
  'braille': CharSet.braille,
  'geometric': CharSet.geometric,
  'mathematical': CharSet.mathematical,
  'linear': CharSet.linear,
  'organic': CharSet.organic,
  'triangular': CharSet.triangular,
  'diamond': CharSet.diamond,
  'extended-ascii': CharSet.extendedAscii,
  'density': CharSet.density,
  'typewriter': CharSet.typewriter,
  'rounded': CharSet.rounded,
  'squared': CharSet.squared,
  'diagonal': CharSet.diagonal,
  'stars': CharSet.stars,
  'circuit': CharSet.circuit,
  'minimal': CharSet.minimal,
  'texture': CharSet.texture,
};

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(
      'input',
      abbr: 'i',
      help: 'Input image file path',
      mandatory: true,
    )
    ..addOption(
      'output',
      abbr: 'o',
      help: 'Output file path (optional, prints to stdout if not specified)',
    )
    ..addOption(
      'width',
      abbr: 'w',
      help: 'Output width in characters',
      defaultsTo: '80',
    )
    ..addOption(
      'charset',
      abbr: 'c',
      help:
          'Character set to use. Use one of predefined preset or provide custom characters',
      defaultsTo: 'standard',
    )
    ..addOption(
      'color',
      help: 'Color mode: grayscale, ansi256, truecolor',
      defaultsTo: 'grayscale',
    )
    ..addOption(
      'char-aspect-ratio',
      abbr: 'a',
      help: 'Character aspect ratio',
      defaultsTo: '0.5',
    )
    ..addFlag(
      'invert',
      help: 'Invert brightness (lighter areas become denser characters)',
      defaultsTo: true,
    )
    ..addFlag(
      'help',
      abbr: 'h',
      help: 'Show this help message',
      negatable: false,
    );

  try {
    final results = parser.parse(arguments);

    if (results['help']) {
      _printHelp(parser);
      return;
    }

    await _processImage(results);
  } catch (e) {
    // ignore: avoid_print
    print('Error: $e\r\n'
        'Call ascii_art --help to see doc');

    exit(1);
  }
}

Future<void> _processImage(ArgResults results) async {
  final inputPath = results['input'] as String;
  final outputPath = results['output'] as String?;
  final width = int.parse(results['width'] as String);
  final charsetName = results['charset'] as String;
  final colorModeName = results['color'] as String;
  final aspectRatio = double.parse(results['char-aspect-ratio'] as String);
  final invert = results['invert'] as bool;

  final inputFile = File(inputPath);
  if (!inputFile.existsSync()) {
    throw ArgumentError('Input file does not exist: $inputPath');
  }

  final charset = charPresets[charsetName] ?? charsetName;
  final colorMode = _parseColorMode(colorModeName);
  final imageBytes = await inputFile.readAsBytes();
  final converter = AsciiConverter();

  IOSink? outputSink;
  if (outputPath != null) {
    outputSink = File(outputPath).openWrite();
  }

  try {
    await converter
        .convertStream(
          imageBytes,
          width: width,
          charset: charset,
          invert: invert,
          colorMode: colorMode,
          charAspectRatio: aspectRatio,
        )
        .forEach(
          (line) =>
              outputSink != null ? outputSink.write(line) : stdout.write(line),
        );

    if (outputPath != null) {
      print('ASCII art saved to: $outputPath');
    }
  } finally {
    await outputSink?.close();
  }
}

ColorMode _parseColorMode(String input) => switch (input.toLowerCase()) {
      'grayscale' => ColorMode.grayscale,
      'ansi256' => ColorMode.ansi256,
      'truecolor' => ColorMode.trueColor,
      _ => throw ArgumentError('Invalid color mode: $input')
    };

void _printHelp(ArgParser parser) => print(
      'ASCII Art Converter\r\n'
      '\r\n'
      'Converts images to ASCII art with customizable character sets and colors.\r\n'
      '\r\n'
      'Options:\r\n'
      '${parser.usage}\r\n'
      '\r\n'
      'Available character sets:\r\n'
      '${charPresets.keys.map((key) => '  $key ${charPresets[key]}').join('\r\n')}\r\n'
      '\r\n'
      'Color modes:\r\n'
      '  grayscale  - No colors (default)\r\n'
      '  ansi256    - 256-color ANSI escape codes\r\n'
      '  truecolor  - 24-bit RGB colors\r\n'
      '\r\n',
    );
