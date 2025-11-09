# 🎨 ASCII Art Converter [![Analyze][analyze-badge]][analyze-link] [![pub package][pub-icon]](https://pub.dev/packages/ascii_art_converter)


A Dart-based ASCII art converter that transforms images into ASCII art. Available as a reusable library and command-line tool.

## ✨ Features

- 🖼️ Convert images to ASCII art
- ⚙️ Customizable output width and character sets
- 🎨 Multiple color modes: grayscale, ANSI 256, true color
- 📦 Available as both library and CLI tool
- ⚡ Fast and lightweight Dart implementation

<img alt="example" src="https://raw.githubusercontent.com/Gj1337/ascii_art_converter/main/doc/gallery.png" />

## 📖 How it works

Check out the [the algorithm](https://github.com/Gj1337/ascii_art_converter/blob/9156cecfbedd814266f37805bbc74e478c51ae4e/doc/how_it_works.md) for details on how each pixel is processed and mapped to ASCII characters.

## 🚀 Installation

### As a Library
Add the package to your `pubspec.yaml`:
```yaml
dependencies:
  ascii_art_converter: ^1.1.0
```
or add the library by command: 
```bash
flutter pub add ascii_art_converter
```

### As a CLI Tool
Activate it globally:
```bash
dart pub global activate ascii_art_converter
```

---

## 🛠️ Usage

### Library Example
```dart
import 'dart:io';
import 'package:ascii_art_converter/ascii_art_converter.dart';

void main() async {
  final bytes = await File('example.png').readAsBytes();
  final ascii = await AsciiConverter().convert(
    bytes,
    width: 100,
    charset: CharSet.standart,
    invert: true,
    colorMode: ColorMode.ansi256,
  );
  print(ascii);
}
```

### CLI Example

```bash
# Convert an image and print to terminal
ascii_art -i cat.png

# Save ASCII art to a file
ascii_art -i cat.png -o cat.txt

# Use custom width
ascii_art -i cat.png -w 120

# Apply a different character set
ascii_art -i cat.png -s blocks
ascii_art -i cat.png -s "@#*+=-:. "   # Custom charset string

# Invert brightness mapping
ascii_art -i cat.png --no-invert

# Enable ANSI 256-color mode
ascii_art -i cat.png --color ansi256

# Enable true color (24-bit RGB) mode
ascii_art -i cat.png --color trueColor

# Adjust character aspect ratio (for fonts with different proportions)
ascii_art -i cat.png -a 0.6

# Show help
ascii_art --help
```


## ⚙️ CLI Options

| Option              | Description                                           | Default   |
|---------------------|-------------------------------------------------------|-----------|
| `-i, --input`       | Input image file path                                 | required  |
| `-o, --output`      | Output file path (optional, prints to stdout)         | stdout    |
| `-w, --width`       | Output width (in characters)                          | `80`      |
| `-s, --charset`     | Character set (preset name or custom string)          | standard  |
| `-c, --color`       | Output color mode: grayscale, ansi256, trueColor      | grayscale |
| `-a, --aspect-ratio`| Character aspect ratio (font width/height ratio)      | `0.5`     |
| `--[no-]invert `    | Invert brightness mapping (dark ↔ light)              | true      |
| `-v, --verbose`     | Print details during execution                        | false     |
| `-h, --help`        | Show help message                                     |           |

---

<!-- Links -->
[analyze-badge]: https://github.com/Gj1337/ascii_art/actions/workflows/analyze.yaml/badge.svg
[analyze-link]: https://github.com/Gj1337/ascii_art/actions/workflows/analyze.yaml
[pub-icon]: https://img.shields.io/pub/v/ascii_art_converter.svg
