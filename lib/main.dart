import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scentswapwebsite/screens/auth/login_screen.dart';
import 'package:scentswapwebsite/screens/auth/register_screen.dart';
import 'package:scentswapwebsite/screens/discover_screen.dart';
import 'package:scentswapwebsite/screens/home_screen.dart';
import 'package:scentswapwebsite/screens/marketplace_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/responsive_provider.dart';
import 'providers/auth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ResponsiveProvider()),
        Provider(create: (_) => AuthController()),
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
            return MaterialApp(
              title: 'ESSENCE - Perfume Marketplace',
              theme: AppTheme.lightTheme(),
              darkTheme: AppTheme.darkTheme(),
              themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              // Keep a short, smooth theme transition
              themeAnimationDuration: const Duration(milliseconds: 200),
              themeAnimationCurve: Curves.easeInOut,
              debugShowCheckedModeBanner: false,
              builder: (context, child) {
                final width = MediaQuery.sizeOf(context).width;
                context.read<ResponsiveProvider>().updateWidth(width);
                return child ?? const SizedBox.shrink();
              },
              routes: {
                '/login': (context) => const LoginScreen(),
                '/register': (context) => const RegisterScreen(),
                '/home': (context) => const HomeScreen(),
                '/discover': (context) => const DiscoverScreen(),
                '/marketplace': (context) => MarketplaceScreen(),
              },
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
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}

