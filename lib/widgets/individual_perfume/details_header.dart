import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';

class DetailsHeader extends SliverPersistentHeaderDelegate {
  DetailsHeader({required this.isDark, required this.colors});

  final bool isDark;
  final ThemeColors colors;

  @override
  double get minExtent => 90.h;

  @override
  double get maxExtent => 90.h;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: isDark ? colors.black : colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacing6.w,
        vertical: AppTheme.spacing4.h,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? colors.white : colors.black,
            width: AppTheme.borderWidth,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'AURA SCENTS',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: isDark ? colors.white : colors.black,
                ),
          ),
          if (MediaQuery.sizeOf(context).width > 720)
            Row(
              children: [
                _headerLink(context, 'Shop', isDark),
                _headerLink(context, 'Archive', isDark),
                _headerLink(context, 'About', isDark),
                _headerLink(context, 'Cart (0)', isDark),
              ],
            )
          else
            Icon(
              Icons.menu,
              color: isDark ? colors.white : colors.black,
              size: 28.sp,
            ),
        ],
      ),
    );
  }

  Widget _headerLink(BuildContext context, String label, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(left: AppTheme.spacing6.w),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: isDark ? colors.white : colors.black,
            ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant DetailsHeader oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}
