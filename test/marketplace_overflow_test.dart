import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:scentswapwebsite/providers/responsive_provider.dart';
import 'package:scentswapwebsite/providers/theme_provider.dart';
import 'package:scentswapwebsite/screens/marketplace_screen.dart';

Future<void> _pumpMarketplace(
  WidgetTester tester,
  Size size,
) async {
  await tester.binding.setSurfaceSize(size);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ResponsiveProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(1440, 900),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            builder: (context, child) {
              context.read<ResponsiveProvider>().updateWidth(
                    MediaQuery.sizeOf(context).width,
                  );
              return child ?? const SizedBox.shrink();
            },
            home: MarketplaceScreen(
              header: const SizedBox.shrink(),
              footer: const SizedBox.shrink(),
            ),
          );
        },
      ),
    ),
  );

  await tester.pumpAndSettle();
}

bool _hasOverflow(List<FlutterErrorDetails> errors) {
  return errors.any(
    (error) => error.exceptionAsString().contains('A RenderFlex overflowed'),
  );
}

testWidgets(
  'Marketplace layout has no overflow on desktop, tablet, and mobile',
  (tester) async {
    final errors = <FlutterErrorDetails>[];
    final original = FlutterError.onError;

    FlutterError.onError = (details) {
      errors.add(details);
    };

    addTearDown(() {
      FlutterError.onError = original;
    });

    await _pumpMarketplace(tester, const Size(1440, 900));
    expect(_hasOverflow(errors), isFalse);
    errors.clear();

    await _pumpMarketplace(tester, const Size(900, 800));
    expect(_hasOverflow(errors), isFalse);
    errors.clear();

    await _pumpMarketplace(tester, const Size(390, 844));
    expect(_hasOverflow(errors), isFalse);
  },
);
