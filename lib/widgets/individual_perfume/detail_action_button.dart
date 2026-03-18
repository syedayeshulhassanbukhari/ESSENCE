import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';

class DetailActionButton extends StatelessWidget {
  const DetailActionButton({
    super.key,
    required this.label,
    required this.background,
    required this.textColor,
    required this.borderColor,
    required this.colors,
  });

  final String label;
  final Color background;
  final Color textColor;
  final Color borderColor;
  final ThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacing6.w,
        vertical: AppTheme.spacing4.h,
      ),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: borderColor, width: AppTheme.borderWidth),
        boxShadow: [
          BoxShadow(
            color: colors.black,
            offset: const Offset(8, 8),
            blurRadius: 0,
          ),
        ],
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w900,
          color: textColor,
        ),
      ),
    );
  }
}
