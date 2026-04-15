import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

import 'package:scentswapwebsite/providers/discover_provider.dart';
import 'package:scentswapwebsite/providers/responsive_provider.dart';
import 'package:scentswapwebsite/providers/theme_provider.dart';
import 'package:scentswapwebsite/screens/discover_screen.dart';
import 'package:scentswapwebsite/services/fragella_api_client.dart';

void main() {
  testWidgets('DiscoverScreen renders without sliver runtime errors', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final mockClient = MockClient((request) async {
      return http.Response('[]', 200);
    });

    final apiClient = FragellaApiClient(
      apiKey: 'test-key',
      baseUrl: 'https://example.com/api/v1',
      httpClient: mockClient,
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => ResponsiveProvider()),
          ChangeNotifierProvider(
            create: (_) => DiscoverProvider(apiClient: apiClient),
          ),
        ],
        child: ScreenUtilInit(
          designSize: const Size(1440, 900),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return const MaterialApp(
              home: DiscoverScreen(),
            );
          },
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    final exception = tester.takeException();
    expect(exception, isNull);
    expect(find.text('The Discovery Lab'), findsOneWidget);
  });
}
