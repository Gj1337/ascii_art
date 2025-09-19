# 🎨 ASCII Art Converter

A Dart-based ASCII art converter that transforms images into ASCII art. Available as a reusable library and command-line tool.


## ✨ Features

- 🖼️ Convert images (PNG, JPG, GIF) to ASCII art
- ⚙️ Customizable output width and character sets
- 🎨 Multiple color modes: grayscale, ANSI 256, true color
- 📦 Available as both library and CLI tool
- ⚡ Fast and lightweight Dart implementation

<img width="2057" height="1977" alt="example" src="https://github.com/user-attachments/assets/e62fc144-eaaa-4638-84a1-915fd784b1b3" />

## 🚀 Installation

### As a Library
Add the package to your `pubspec.yaml`:
```yaml
dependencies:
  ascii_art:
    git:
      url: https://github.com/Gj1337/ascii_art.git
```

### As a CLI Tool
Activate it globally:
```bash
dart pub global activate --source git https://github.com/Gj1337/ascii_art.git
```

---

## 🛠️ Usage

### Library Example
```dart
import 'dart:io';
import 'package:ascii_art/ascii_art.dart';

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
ascii_art -i cat.png -c blocks
ascii_art -i cat.png -c "@#*+=-:. "   # Custom charset string

# Invert brightness mapping
ascii_art -i cat.png --invert=false

# Enable ANSI 256-color mode
ascii_art -i cat.png --color ansi256

# Enable true color (24-bit RGB) mode
ascii_art -i cat.png --color truecolor

# Adjust character aspect ratio (for fonts with different proportions)
ascii_art -i cat.png -a 0.6

# Show help
ascii_art --help
```


## ⚙️ CLI Options

| Option              | Description                                           | Default   |
|---------------------|-------------------------------------------------------|-----------|
| `-i, --input`       | Input image file path                                | required  |
| `-o, --output`      | Output file path (optional, prints to stdout)         | stdout    |
| `-w, --width`       | Output width (in characters)                         | `80`      |
| `-c, --charset`     | Character set (preset name or custom string)          | standard  |
| `--color`           | Output color mode: grayscale, ansi256, truecolor      | grayscale |
| `-a, --aspect-ratio`| Character aspect ratio (font width/height ratio)      | `0.5`     |
| `--invert`          | Invert brightness mapping (dark ↔ light)              | true      |
| `-h, --help`        | Show help message                                    |           |

---


## 📂 Project Structure

```
.
├── bin/
│   └── ascii_art.dart        # CLI entry point
├── lib/
│   ├── ascii_art.dart        # Library entry point
│   └── src/
│       ├── ascii_converter.dart      # Core conversion logic
│       ├── char_set.dart             # Predefined character sets
│       └── color_mode.dart           # Color mode definitionsl
├── example/
│   └── example.dart          # Example usage
├── test/                     # Unit tests
├── pubspec.yaml
└── README.md
```

