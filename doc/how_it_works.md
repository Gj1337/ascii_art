# 🔍 How It Works

The ASCII Art Converter transforms images into ASCII art by mapping pixel brightness (and optionally color) to characters.  

Here’s the step-by-step principle of operation:

---

## 1. 🖼️ Load & Decode Image
- The input image (PNG, JPG, GIF, etc.) is read as raw bytes.
- The `image` Dart package decodes these bytes into a pixel matrix.
- Each pixel contains **RGB values** (and alpha channel if present).

---

## 2. 📐 Resize for ASCII Grid
- Since characters are not square (they’re typically taller than wide), the image must be resized.
- The target width is set by the user (e.g., `-w 80`).
- The height is calculated using an **aspect ratio correction factor** (default `0.5`) so the ASCII output looks proportional. Because by default in most fonts a symbol isn't a squre but rather a rectangle. 

Example:
```dart
targetHeight = width * (imageHeight / imageWidth) * charAspectRatio
```

---

## 3. 💡 Brightness Calculation
- For each pixel, brightness (luminance) is calculated from its RGB values:

```dart
brightness = 0.299 * Red + 0.587 * Green + 0.114 * Blue;
//or use "package:image.dart" method 
brightness = image.getLuminance(pixel);
```

- Brightness ranges from `0` (black) to `255` (white).

---

## 4. 🔠 Map Brightness → Characters
- A **charset** (string of characters ordered from darkest to lightest) is used.
  - Example: `@#*+=-:. `
- The pixel’s brightness value determines which character to pick:
```dart
index = (brightness * (charset.length - 1)) / 255
char  = charset[index]
```
- Optionally, if `--invert` is enabled, brightness is flipped:
```dart
brightness = 255 - brightness
```

---

## 5. 🎨 Apply Color (Optional)
Depending on the chosen mode:
- **Grayscale** → plain characters only
- **ANSI 256** → maps pixel color into one of 256 terminal colors
- **TrueColor** → outputs full 24-bit RGB ANSI escape codes

```dart
String _getTrueColor(img.Color pixel) {
    final r = pixel.r.toInt();
    final g = pixel.g.toInt();
    final b = pixel.b.toInt();

    return '\x1b[38;2;$r;$g;${b}m';
  }

  ...

  final color = _getTrueColor(pixel);
  final coloredChar = '$color$char';
```

Each character is prefixed with the color code and the line ends with a reset code (`x1b[0m`).

---

## 6. 📝 Output Assembly
- Characters are written row by row, forming ASCII art lines.
- Each row ends with a newline (`\r\n`).
- The final output can be:
  - Printed to the terminal (default)
  - Written to a file (`-o output.txt`)

---

## ⚡ Summary
1. Decode → 2. Resize → 3. Brightness → 4. Char Mapping → 5. Color → 6. Output  

This pipeline ensures that every pixel in the source image has a corresponding character in the ASCII representation, preserving overall structure and tone.
