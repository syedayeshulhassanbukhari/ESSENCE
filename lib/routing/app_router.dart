import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/discover_screen.dart';
import '../screens/home_screen.dart';
import '../screens/individual_perfume_details.dart';
import '../screens/marketplace_screen.dart';
import '../screens/admin_panel_screen.dart';
import '../screens/exchange_listing_detail_screen.dart';

class AppRouter {
  AppRouter({
    this.transitionDuration = const Duration(milliseconds: 220),
    this.transitionCurve = Curves.easeOutCubic,
  });

  final Duration transitionDuration;
  final Curve transitionCurve;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static final Map<String, Widget Function(RouteSettings settings)> _routes = {
    '/login': (_) => const LoginScreen(),
    '/register': (_) => const RegisterScreen(),
    '/home': (_) => const HomeScreen(),
    '/discover': (_) => const DiscoverScreen(),
    '/marketplace': (_) => MarketplaceScreen(),
    '/individualDetails': (_) => IndividualPerfumeDetails(),
    '/admin': (_) => const AdminPanelScreen(),
    '/exchangeListingDetail': (_) => const ExchangeListingDetailScreen(),
  };

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final builder = _routes[settings.name];
    final page = builder != null ? builder(settings) : const HomeScreen();
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: transitionDuration,
      reverseTransitionDuration: transitionDuration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(parent: animation, curve: transitionCurve);
        final fade = FadeTransition(opacity: curve, child: child);
        return ScaleTransition(
          scale: Tween<double>(begin: 0.98, end: 1.0).animate(curve),
          child: fade,
        );
      },
    );
  }

  void replaceWithFade(String routeName, {Object? arguments}) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      return;
    }
    final settings = RouteSettings(name: routeName, arguments: arguments);
    final route = onGenerateRoute(settings);
    navigator.pushReplacement(route);
  }
}
