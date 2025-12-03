class HtmlUtils {
  static const String placeholder = '--/--';

  static String htmlToPlain(String? html) {
    final s = (html ?? '').trim();
    if (s.isEmpty) return '';

    var out = s;

    out = out.replaceAll(RegExp(r'<li[^>]*>', caseSensitive: false), '\n- ');
    out = out.replaceAll(RegExp(r'</li>', caseSensitive: false), '');
    out = out.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    out = out.replaceAll(RegExp(r'</p>', caseSensitive: false), '\n');
    out = out.replaceAll(RegExp(r'<p[^>]*>', caseSensitive: false), '');
    out = out.replaceAll(RegExp(r'<[^>]+>'), '');
    out = out.replaceAll('&nbsp;', ' ').replaceAll('&amp;', '&');
    out = out.replaceAll(RegExp(r'\)\s*;\s*\+', caseSensitive: false), ')\n- ');
    out = out.replaceAll(RegExp(r';\s*\+', caseSensitive: false), ';\n- ');
    out = out.replaceAll(RegExp(r':\s*\+', caseSensitive: false), ':\n- ');
    out = out.replaceAll(RegExp(r'(^|\n)\s*\+\s*'), '\n- ');
    out = out.replaceAll(RegExp(r':\+'), ':\n- ');
    out = out.replaceAll(RegExp(r';\s*\n\s*-'), '\n- ');
    out = out.replaceAllMapped(RegExp(r'(\n|^)\+(\d)'), (m) => '\n- ${m[2]}');

    final lines =
        out
            .split('\n')
            .map((l) => l.replaceAll(RegExp(r'\s+'), ' ').trim())
            .toList();
    final filtered = <String>[];
    for (var line in lines) {
      if (line.isEmpty) {
        if (filtered.isNotEmpty && filtered.last.isEmpty) continue;
        filtered.add('');
      } else {
        filtered.add(line);
      }
    }

    var result = filtered.join('\n').trim();
    result = result.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    result = result.replaceFirst(RegExp(r'^\-+\s*'), '- ').trimLeft();

    return result;
  }

  static String displayOrPlaceholder(
    String? s, {
    bool usePlaceholderWhenEmpty = false,
  }) {
    final v = (s ?? '').trim();
    if (v.isEmpty && usePlaceholderWhenEmpty) return placeholder;
    return (v.isEmpty || v == 'null') ? placeholder : v;
  }

  static String stripTags(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
