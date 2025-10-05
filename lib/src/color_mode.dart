/// Defines the color output modes for ASCII art generation.
///
/// Controls how colors from the original image are represented in the
/// ASCII art output. Different modes offer trade-offs between color
/// accuracy and terminal compatibility.
enum ColorMode {
  /// No color output - pure grayscale ASCII art.
  ///
  /// The output contains only characters without any ANSI color codes.
  /// This is the default mode and works in all terminals. Best for
  /// printing to files or terminals without color support.
  grayscale,

  /// 256-color ANSI escape codes.
  ///
  /// Uses the ANSI 256-color palette (6x6x6 color cube) for colored output.
  /// Provides good color representation with broad terminal compatibility.
  /// Most modern terminals support this mode.
  ansi256,

  /// 24-bit RGB true color.
  ///
  /// Uses full RGB color values for maximum color accuracy.
  /// Requires a terminal with true color support (most modern terminals).
  /// Provides the most accurate color representation of the original image.
  trueColor,
}
