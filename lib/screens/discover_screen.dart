import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/responsive_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/layout_widgets.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? AppTheme.backgroundLight
          : AppTheme.backgroundDark,
      body: Column(
        children: [
          const AppHeader(),
          Expanded(
            child: ResponsiveLayout(
              child: Center(
                child: Text(
                  'Discover Page',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontSize: context.select<ResponsiveProvider, bool>(
                                (provider) => provider.isSmall)
                            ? 32.sp
                            : 48.sp,
                      ),
                ),
              ),
            ),
          ),
          const AppFooter(),
        ],
      ),
    );
  }
}