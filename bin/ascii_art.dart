import 'dart:io';
import 'package:args/args.dart';
import 'package:ascii_art/ascii_art.dart';

const toolName = 'ascii_art';

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

typedef ImageProcessArguments = ({
  File file,
  String? outputPath,
  int width,
  String charSet,
  ColorMode colorMode,
  double aspectRatio,
  bool invert
});

void main(List<String> arguments) async {
  final parser = ArgParser(usageLineLength: 80)
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
      'char-aspect-ratio',
      abbr: 'a',
      help: 'Character aspect ratio',
      defaultsTo: '0.5',
    )
    ..addFlag(
      'invert',
      help: 'Invert brightness (lighter areas become denser characters).',
      defaultsTo: true,
    )
    ..addOption(
      'color',
      abbr: 'c',
      help: 'Color mode',
      defaultsTo: 'grayscale',
      allowed: ColorMode.values
          .map((mode) => mode.toString().replaceFirst('ColorMode.', '')),
      allowedHelp: {
        'grayscale': 'No colors',
        'ansi256': '256-color ANSI escape codes',
        'trueColor': '24-bit RGB colors',
      },
    )
    ..addOption(
      'charset',
      abbr: 's',
      help:
          'Character set to use. Use one of predefined preset or provide custom characters',
      defaultsTo: 'standard',
      allowedHelp: charPresets,
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

    final imageProcessArguments = _processArguments(results);

    await _processImage(imageProcessArguments);
  } catch (e) {
    print('Error: $e\r\n'
        'Call $toolName --help to see doc');

    exit(1);
  }
}

ImageProcessArguments _processArguments(ArgResults arguments) {
  final inputPath = (arguments['input'] as String);
  final outputPath = arguments['output'] as String?;
  final width = int.parse(arguments['width'] as String);
  final charsetName = arguments['charset'] as String;
  final colorModeName = arguments['color'] as String;
  final aspectRatio = double.parse(arguments['char-aspect-ratio'] as String);
  final invert = arguments['invert'] as bool;

  final file = File(inputPath);
  if (!file.existsSync()) {
    throw ArgumentError('Input file does not exist: $inputPath');
  }
  final charSet = charPresets[charsetName] ??
      charsetName; //substring to get rid of quotes ""
  final colorMode = _parseColorMode(colorModeName);

  return (
    file: file,
    outputPath: outputPath,
    width: width,
    charSet: charSet,
    colorMode: colorMode,
    aspectRatio: aspectRatio,
    invert: invert
  );
}

Future<void> _processImage(ImageProcessArguments argmunents) async {
  final (
    :file,
    :outputPath,
    :width,
    :charSet,
    :colorMode,
    :aspectRatio,
    :invert
  ) = argmunents;

  final imageBytes = await file.readAsBytes();
  final converter = AsciiConverter();

  IOSink? outputSink;
  if (outputPath != null) {
    outputSink = File(outputPath).openWrite();
  }

  try {
    final convertStream = converter.convertStream(
      imageBytes,
      width: width,
      charset: charSet,
      invert: invert,
      colorMode: colorMode,
      charAspectRatio: aspectRatio,
    );

    await convertStream.forEach(
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
      'Converts images to ASCII art with customizable character sets and colors.\r\n'
      '\r\n'
      'Options:\r\n'
      '${parser.usage}\r\n',
    );
