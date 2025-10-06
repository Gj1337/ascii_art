import 'dart:io';
import 'package:ascii_art_converter/ascii_art_converter.dart';

void main() async {
  const filePath = 'image.png'; //Change to a valid file path
  final image = File(filePath);
  final imageBytes = await image.readAsBytes();
  const converter = AsciiArtConverter();
  final art = await converter.convert(imageBytes);

  print(art);
}
