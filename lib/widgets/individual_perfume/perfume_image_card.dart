import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';

class PerfumeImageCard extends StatelessWidget {
  const PerfumeImageCard({
    super.key,
    required this.imageUrl,
    required this.isDark,
    required this.colors,
  });

  final String imageUrl;
  final bool isDark;
  final ThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing4.w),
      decoration: BoxDecoration(
        color: colors.white,
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
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: isDark ? colors.zinc900 : colors.white,
      child: Icon(
        Icons.local_florist,
        size: 64.sp,
        color: colors.gray400,
      ),
    );
  }
}
