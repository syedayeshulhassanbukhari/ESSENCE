import '../models/discover_badge_style.dart';
import '../models/discover_card_presentation.dart';
import '../models/discover_color_token.dart';
import '../models/discover_filter.dart';
import '../models/fragella_fragrance.dart';

class DiscoverPresentationService {
  const DiscoverPresentationService();

  List<DiscoverFilter> buildFilters(List<FragellaFragrance> items) {
    final tokens = <DiscoverFilter>[];
    final seen = <String>{};

    for (final item in items) {
      for (final accord in item.mainAccords) {
        final label = _capitalize(accord.trim());
        if (label.isEmpty) {
          continue;
        }

        final key = label.toLowerCase();
        if (seen.contains(key)) {
          continue;
        }

        seen.add(key);
        tokens.add(
          DiscoverFilter(
            label: label,
            colorToken: _colorTokenForAccord(label),
          ),
        );

        if (tokens.length >= 5) {
          return tokens;
        }
      }
    }

    return const [
      DiscoverFilter(label: 'Woody', colorToken: DiscoverColorToken.lime),
      DiscoverFilter(label: 'Floral', colorToken: DiscoverColorToken.white),
      DiscoverFilter(label: 'Citrus', colorToken: DiscoverColorToken.orange),
      DiscoverFilter(label: 'Oud', colorToken: DiscoverColorToken.white),
      DiscoverFilter(label: 'Spicy', colorToken: DiscoverColorToken.pink),
    ];
  }

  DiscoverCardPresentation buildCardPresentation(FragellaFragrance fragrance) {
    return DiscoverCardPresentation(
      backgroundToken: _backgroundToken(fragrance),
      badge: _badgeFor(fragrance),
    );
  }

  DiscoverColorToken _backgroundToken(FragellaFragrance fragrance) {
    final accords = fragrance.mainAccords.map((e) => e.toLowerCase()).toList();

    if (accords.any((value) => value.contains('woody'))) {
      return DiscoverColorToken.lime;
    }
    if (accords.any((value) => value.contains('citrus'))) {
      return DiscoverColorToken.orange;
    }
    if (accords.any((value) => value.contains('floral'))) {
      return DiscoverColorToken.pink;
    }
    if (accords.any((value) => value.contains('aquatic')) ||
        accords.any((value) => value.contains('fresh'))) {
      return DiscoverColorToken.blue;
    }
    if (fragrance.gender.toLowerCase().contains('men')) {
      return DiscoverColorToken.black;
    }
    return DiscoverColorToken.white;
  }

  DiscoverBadgeStyle _badgeFor(FragellaFragrance fragrance) {
    final popularity = fragrance.popularity.toLowerCase();
    if (popularity.contains('very high')) {
      return const DiscoverBadgeStyle('BESTSELLER', true);
    }
    if (fragrance.confidence.toLowerCase() == 'high') {
      return const DiscoverBadgeStyle('HOT', false);
    }
    if (fragrance.year.isNotEmpty) {
      return const DiscoverBadgeStyle('NEW', false);
    }
    return const DiscoverBadgeStyle('DISCOVER', true);
  }

  DiscoverColorToken _colorTokenForAccord(String accord) {
    final normalized = accord.toLowerCase();
    if (normalized.contains('woody') || normalized.contains('green')) {
      return DiscoverColorToken.lime;
    }
    if (normalized.contains('citrus') || normalized.contains('orange')) {
      return DiscoverColorToken.orange;
    }
    if (normalized.contains('floral') || normalized.contains('rose')) {
      return DiscoverColorToken.pink;
    }
    return DiscoverColorToken.white;
  }

  String _capitalize(String text) {
    if (text.isEmpty) {
      return text;
    }
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }
}