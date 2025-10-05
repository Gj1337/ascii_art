/// Predefined character sets for ASCII art conversion.
///
/// Each set is ordered from darkest (space) to lightest (densest character).
/// The converter maps pixel brightness to these characters.
abstract final class CharSet {
  /// Standard ASCII set: ` .:-=+*#%@`
  ///
  /// Balanced detail with 10 brightness levels. Default choice.
  static const String standart = r' .:-=+*#%@';

  /// Block characters: ` ░▒▓█`
  ///
  /// Retro pixel-art style with 5 shading levels.
  static const String blocks = r' ░▒▓█';

  /// Minimalist set: ` .*#`
  ///
  /// Simple 4-character set for quick, low-detail conversions.
  static const String simple = r' .*#';

  /// Binary style: ` .#`
  ///
  /// High-contrast, dithered look with 3 characters.
  static const String binary = r' .#';

  /// Extreme contrast: ` █`
  ///
  /// Silhouette-style with no intermediate tones.
  static const String highContrast = r' █';

  /// Smooth gradient: ` ▏▎▍▌▋▊▉█`
  ///
  /// Unicode blocks providing 8 levels of smooth shading.
  static const String shadedBlocks = ' ▏▎▍▌▋▊▉█';

  /// Braille patterns: ` ⠁⠃⠇⠧⠷⠿`
  ///
  /// Dot-matrix style using Braille characters.
  static const String braille = r' ⠁⠃⠇⠧⠷⠿';

  /// Geometric circles: ` ·∘○●◦◯⬤`
  ///
  /// Modern look with rounded, organic patterns.
  static const String geometric = r' ·∘○●◦◯⬤';

  /// Mathematical symbols: ` ∙∘○●∞∫∬∭`
  ///
  /// Academic aesthetic combining circles with math notation.
  static const String mathematical = r' ∙∘○●∞∫∬∭';

  /// Linear dashes: ` -–—━▬`
  ///
  /// Horizontal line patterns with varying weights.
  static const String linear = r' -–—━▬';

  /// Wave characters: ` ~∼≈∽∿`
  ///
  /// Flowing, fluid patterns with approximation symbols.
  static const String organic = r' ~∼≈∽∿';

  /// Triangle shapes: ` ▵▴▲▼▽▾`
  ///
  /// Angular, geometric art with directional triangles.
  static const String triangular = r' ▵▴▲▼▽▾';

  /// Diamond shapes: ` ◇◈◉◊◆♦`
  ///
  /// Decorative patterns with hollow and filled diamonds.
  static const String diamond = r' ◇◈◉◊◆♦';

  /// Extended ASCII: ` ░▒▓█▀▄▌▐`
  ///
  /// Shading combined with half-block characters for varied textures.
  static const String extendedAscii = r' ░▒▓█▀▄▌▐';

  /// High-detail set: ` .,:;i1tfLCG08@`
  ///
  /// 15 brightness levels for photorealistic ASCII art.
  static const String density = r' .,:;i1tfLCG08@';

  /// Typewriter style: ` .,":;!*oO8&@`
  ///
  /// Classic ASCII art with punctuation and letters.
  static const String typewriter = r' .,":;!*oO8&@';

  /// Circular shapes: ` ∘○◯●⬤`
  ///
  /// Clean, rounded appearance with progressively filled circles.
  static const String rounded = r' ∘○◯●⬤';

  /// Square shapes: ` ▫▪▫◻◼█`
  ///
  /// Blocky, grid-like patterns with hollow and filled boxes.
  static const String squared = r' ▫▪▫◻◼█';

  /// Diagonal lines: ` ╱╲╳▓██`
  ///
  /// Slanted, cross-hatched patterns with diagonal emphasis.
  static const String diagonal = r' ╱╲╳▓██';

  /// Star symbols: ` ·✦✧✩✪★`
  ///
  /// Starry, glittering patterns with various star shapes.
  static const String stars = r' ·✦✧✩✪★';

  /// Box-drawing characters: ` ─│┌┐└┘├┤┬┴┼`
  ///
  /// Technical, circuit-like appearance with line connections.
  static const String circuit = r' ─│┌┐└┘├┤┬┴┼';

  /// Ultra-minimal: ` ·•●`
  ///
  /// Three-character dot progression for abstract representations.
  static const String minimal = r' ·•●';

  /// Textured patterns: ` ░▒▓▞▚▟▛▜`
  ///
  /// Complex textures with shading and half-block combinations.
  static const String texture = r' ░▒▓▞▚▟▛▜';
}
