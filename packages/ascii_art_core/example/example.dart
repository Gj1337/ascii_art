import 'dart:io';
import 'package:ascii_art_core/ascii_art_core.dart';

void main() {
  final converter = AsciiConverter();

  print('🎨 ASCII Art Converter Example');
  print('================================');
  stdout.write('Enter image path: ');
  final imagePath = stdin.readLineSync()?.trim();
  
  print('IMAGE PATH $imagePath');

  if (imagePath == null || imagePath.isEmpty) {
    print('❌ No image path provided');
    return;
  }

  stdout.write('Enter width (default 80): ');
  final widthInput = stdin.readLineSync();
  final width = int.tryParse(widthInput ?? '') ?? 80;

  print('\nChoose character set:');
  print('1. Default ( .:-=+*#%@)');
  print('2. Blocks ( ░▒▓█)');
  print('3. Simple ( .*#)');

  stdout.write('Choice (1-4, default 1): ');

  final choiceInput = stdin.readLineSync() ?? '1';
  final charset = switch (choiceInput) {
    '2' => ' ░▒▓█',
    '3' => ' .*#',
    _ => AsciiConverter.defaultCharset
  };

  try {
    print('\n🔄 Converting image...');

    // Test both methods
    final pixelArt = converter.convertImage(
      imagePath,
      width: width,
      charset: charset,
    );

    print('\n✅ Conversion complete!\n');
    print(pixelArt);

    // Ask if user wants to save to file
    stdout.write('\nSave as txt file? (y/N): ');
    final saveChoice = stdin.readLineSync()?.toLowerCase();

    if (saveChoice?.toLowerCase() == 'y') {
      stdout.write('Enter output filename: ');
      final filename = stdin.readLineSync();

      if (filename != null && filename.isNotEmpty) {
        File('$filename.txt').writeAsStringSync(pixelArt);

        print('💾 Saved to $filename');
      }
    }
  } catch (e) {
    print('❌ Error: $e');
  }
}
