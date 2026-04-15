import 'discover_badge_style.dart';
import 'discover_color_token.dart';

class DiscoverCardPresentation {
  const DiscoverCardPresentation({
    required this.backgroundToken,
    required this.badge,
  });

  final DiscoverColorToken backgroundToken;
  final DiscoverBadgeStyle badge;
}