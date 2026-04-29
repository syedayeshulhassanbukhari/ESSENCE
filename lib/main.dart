import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:scentswapwebsite/screens/auth/login_screen.dart';
// import 'package:scentswapwebsite/screens/auth/register_screen.dart';
// import 'package:scentswapwebsite/screens/discover_screen.dart';
import 'package:scentswapwebsite/screens/home_screen.dart';
// import 'package:scentswapwebsite/screens/individual_perfume_details.dart';
// import 'package:scentswapwebsite/screens/marketplace_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'config/marketplace_exchange_config.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/responsive_provider.dart';
import 'providers/auth_controller.dart';
import 'providers/discover_provider.dart';
import 'providers/home_featured_provider.dart';
import 'services/fragella_api_client.dart';
import 'config/fragella_config.dart';
import 'routing/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/.env');
  if (MarketplaceExchangeConfig.supabaseUrl.isEmpty ||
      MarketplaceExchangeConfig.supabasePublishableKey.isEmpty) {
    throw Exception(
      'Missing SUPABASE_URL or SUPABASE_PUBLISHABLE_KEY (or SUPABASE_ANON_KEY) in assets/.env',
    );
  }
  if (!MarketplaceExchangeConfig.supabaseUrl.startsWith('http')) {
    throw Exception(
      'SUPABASE_URL must be a project URL like https://<project-ref>.supabase.co',
    );
  }
  await Supabase.initialize(
    url: MarketplaceExchangeConfig.supabaseUrl,
    anonKey: MarketplaceExchangeConfig.supabasePublishableKey,
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => AppRouter()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ResponsiveProvider()),
        Provider(create: (_) => AuthController()),
        Provider(
          create: (_) => FragellaApiClient(
            apiKey: FragellaConfig.apiKey,
            baseUrl: FragellaConfig.baseUrl,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => DiscoverProvider(
            apiClient: context.read<FragellaApiClient>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => HomeFeaturedProvider(
            apiClient: context.read<FragellaApiClient>(),
          ),
        ),
      ],
      child: const ScentSwapApp(),
    ),
  );
}

class ScentSwapApp extends StatelessWidget {
  const ScentSwapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return ScreenUtilInit(
          designSize: const Size(1440, 900),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            final appRouter = context.read<AppRouter>();
            return MaterialApp(
              title: 'ESSENCE - Perfume Marketplace',
              theme: AppTheme.lightTheme(themeProvider.colors),
              darkTheme: AppTheme.darkTheme(themeProvider.colors),
              themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              // Keep a short, smooth theme transition
              themeAnimationDuration: const Duration(milliseconds: 200),
              themeAnimationCurve: Curves.easeInOut,
              debugShowCheckedModeBanner: false,
              builder: (context, child) {
                final width = MediaQuery.sizeOf(context).width;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.read<ResponsiveProvider>().updateWidth(width);
                });
                return child ?? const SizedBox.shrink();
              },
              navigatorKey: appRouter.navigatorKey,
              onGenerateRoute: appRouter.onGenerateRoute,
              home: const _AuthGate(),
            );
          },
        );
      },
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    // Dev bypass: show the post-auth screen directly.
    return const HomeScreen();

    // Original auth gate logic (kept for re-enable):
    // return StreamBuilder<User?>(
    //   stream: FirebaseAuth.instance.authStateChanges(),
    //   builder: (context, snapshot) {
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       return const Scaffold(
    //         body: Center(child: CircularProgressIndicator()),
    //       );
    //     }
    //
    //     if (snapshot.hasData) {
    //       return const HomeScreen();
    //     }
    //
    //     return const LoginScreen();
    //   },
    // );
  }
}

