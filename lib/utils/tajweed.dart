import 'package:flutter/material.dart';

/// Tajweed color map for the Tanzil `quran-tajweed` edition tags.
///
/// The quran-tajweed edition wraps colored segments in markers like:
///   [m[ ... ]  (red)      [n[ ... ]  (green)
///   [h:N[ ... ] (blue)    [u:N[ ... ] (purple)
///   [p[ ... ]  (teal)     [i[ ... ]  (emphasis/orange)
///   [f[ ... ]  (lengthened, same as madd)
///   [w[ ... ]  (silent letter)
///   [e[ ... ]  (echo / small meem)
///   [q[ ... ]  (stop mark)
///   [a[ ... ]  (madd wajib)
///   [l[ ... ]  (laam shamsiyya / normal)
///
/// Each opening tag pairs with a closing `]` that is NOT preceded by another
/// opening bracket group. The simplest robust approach: scan char-by-char,
/// detect `[x[` or `[x:N[` openers, push a color, and treat the very next `]`
/// as the closer for the most recent opener.
class TajweedColors {
  // Single-letter tag -> color (matches the common Tajweed color scheme used
  // by the QuranReader / Tanzil web app).
  static const Map<String, Color> tagColors = {
    'm': Color(0xFFE57373), // madd (lengthened vowel) - red
    'n': Color(0xFF66BB6A), // nasalization / ghunnah - green
    'h': Color(0xFF42A5F5), // ghunnah - blue
    'u': Color(0xFFAB47BC), // qalaqah - purple
    'p': Color(0xFF26A69A), // ikhfa - teal
    'i': Color(0xFFEF9A3D), // emphasis - orange
    'f': Color(0xFFE57373), // lengthened (same as madd) - red
    'a': Color(0xFFD32F2F), // madd wajib munfasil - strong red
    'w': Color(0xFF9E9E9E), // silent - grey (subtle)
    'e': Color(0xFF8D6E63), // echo / small meem - brown
    'q': Color(0xFFB71C1C), // stop mark - dark red
    'l': Color(0xFF000000), // normal / laam - keep base
  };
}

/// Parse Tanzil tajweed-tagged text into a list of [TextSpan]s.
///
/// [baseStyle] is applied to plain (un-tagged) text. Tagged segments get the
/// tag's color while inheriting size/weight from [baseStyle].
List<TextSpan> parseTajweed(String text, TextStyle baseStyle) {
  final List<TextSpan> spans = [];
  final StringBuffer buffer = StringBuffer();
  Color? currentColor;

  int i = 0;
  final int len = text.length;
  while (i < len) {
    final String ch = text[i];

    // Detect an opening tag: '[' followed by a single letter then '['.
    if (ch == '[' && i + 2 < len && text[i + 2] == '[') {
      final String tag = text[i + 1];
      // Some tags carry a numeric param: [h:11[  -> tag letter 'h'
      String letter = tag;
      int openEnd = i + 2; // index of the second '['
      if (tag == 'h' || tag == 'u') {
        // allow optional ":N" before the closing '['  e.g. [h:11[
        final int colon = text.indexOf(':', i + 1);
        if (colon != -1 && colon < len && text[colon + 1] != '[') {
          // find the '[' after the colon
          final int closeBracket = text.indexOf('[', colon);
          if (closeBracket != -1) {
            letter = tag;
            openEnd = closeBracket;
          }
        }
      }

      // Flush any buffered plain text first.
      if (buffer.isNotEmpty) {
        spans.add(TextSpan(
          text: buffer.toString(),
          style: baseStyle.copyWith(color: currentColor ?? baseStyle.color),
        ));
        buffer.clear();
      }

      currentColor = TajweedColors.tagColors[letter] ?? baseStyle.color;
      i = openEnd + 1; // move past the opening '['
      continue;
    }

    // Detect a closing ']' that closes the most recent opener.
    if (ch == ']' && currentColor != null) {
      if (buffer.isNotEmpty) {
        spans.add(TextSpan(
          text: buffer.toString(),
          style: baseStyle.copyWith(color: currentColor),
        ));
        buffer.clear();
      }
      currentColor = null;
      i++;
      continue;
    }

    buffer.write(ch);
    i++;
  }

  // Flush remaining buffer.
  if (buffer.isNotEmpty) {
    spans.add(TextSpan(
      text: buffer.toString(),
      style: baseStyle.copyWith(color: currentColor ?? baseStyle.color),
    ));
  }

  return spans;
}

/// Strip all tajweed tags from a string, returning the bare Arabic text.
String stripTajweed(String text) {
  return text.replaceAll(RegExp(r'\[[^\]]*\['), '').replaceAll(']', '');
}
