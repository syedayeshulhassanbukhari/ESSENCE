import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';
import 'detail_action_button.dart';

class PerfumeCtaSection extends StatelessWidget {
  const PerfumeCtaSection({
    super.key,
    required this.isDark,
    required this.colors,
    required this.accentCyan,
  });

  final bool isDark;
  final ThemeColors colors;
  final Color accentCyan;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing6.w),
      decoration: BoxDecoration(
        color: accentCyan,
        border: Border.all(
          color: isDark ? colors.white : colors.black,
          width: AppTheme.borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.black,
            offset: const Offset(8, 8),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Don\'t just exist.\nLEAVE A MARK.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                ),
          ),
          SizedBox(height: AppTheme.spacing4.h),
          Text(
            'Limited batch production. 042/500 units remaining.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: AppTheme.spacing4.h),
          DetailActionButton(
            label: 'Get the Drift',
            background: colors.white,
            textColor: colors.black,
            borderColor: colors.black,
            colors: colors,
          ),
        ],
      ),
    );
  }
}
