import 'package:html/parser.dart' as html_parser;
import '../../../../core/config/app_config.dart';

/// The backend hands back `body` as raw HTML scraped straight from the
/// company's public site (see the sample in `GET /contents/{id}` - a hidden
/// text-to-speech audio player, `img` tags pointing at paths relative to
/// that site, a leftover `face` attribute from its face-detection widget,
/// etc.). This tidies that markup up before it reaches `flutter_html`:
/// drops elements it can't/shouldn't render, and rewrites image `src`
/// paths to absolute URLs the same way [AppConfig.resolveMediaUrl] does
/// for every other media field.
class ScrapedHtmlSanitizer {
  ScrapedHtmlSanitizer._();

  static const _disallowedSelectors = [
    'script',
    'style',
    'iframe',
    'audio',
    '.tts-parent',
  ];

  static String clean(String rawHtml) {
    if (rawHtml.trim().isEmpty) return '';

    final document = html_parser.parse(rawHtml);

    for (final selector in _disallowedSelectors) {
      for (final element in document.querySelectorAll(selector).toList()) {
        element.remove();
      }
    }

    for (final img in document.querySelectorAll('img')) {
      final src = img.attributes['src'];
      if (src != null && src.isNotEmpty) {
        img.attributes['src'] = AppConfig.resolveMediaUrl(src);
      }
      img.attributes.remove('face');
    }

    return document.body?.innerHtml ?? rawHtml;
  }
}
