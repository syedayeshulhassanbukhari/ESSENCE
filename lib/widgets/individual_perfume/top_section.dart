import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../models/fragella_fragrance.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';
import 'detail_action_button.dart';
import 'perfume_image_card.dart';

class PerfumeTopSection extends StatelessWidget {
  const PerfumeTopSection({
    super.key,
    required this.data,
    required this.nameParts,
    required this.description,
    required this.isDark,
    required this.colors,
    required this.primary,
    required this.accentCyan,
  });

  final FragellaFragrance data;
  final List<String> nameParts;
  final String description;
  final bool isDark;
  final ThemeColors colors;
  final Color primary;
  final Color accentCyan;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final image = PerfumeImageCard(
          imageUrl: data.imageUrl,
          isDark: isDark,
          colors: colors,
        );
        final detail = _buildDetailCard(context);

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: image),
              SizedBox(width: AppTheme.spacing8.w),
              Expanded(child: detail),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            image,
            SizedBox(height: AppTheme.spacing6.h),
            detail,
          ],
        );
      },
    );
  }

  Widget _buildDetailCard(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w900,
          color: colors.black,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.spacing2.w,
            vertical: AppTheme.spacing2.h,
          ),
          decoration: BoxDecoration(
            color: accentCyan.withOpacity(0.2),
            border: Border.all(
              color: isDark ? colors.white : colors.black,
              width: AppTheme.borderWidth / 2,
            ),
          ),
          child: Text(
            data.oilType.isNotEmpty ? data.oilType : 'Eau de Parfum',
            style: labelStyle,
          ),
        ),
        SizedBox(height: AppTheme.spacing4.h),
        Text(
          nameParts.join('\n'),
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 72.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.5,
                height: 0.95,
              ),
        ),
        SizedBox(height: AppTheme.spacing4.h),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: AppTheme.spacing6.h),
        Text(
          data.price.isNotEmpty ? '\$${data.price}' : '\$185.00',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
              ),
        ),
        SizedBox(height: AppTheme.spacing6.h),
        Wrap(
          spacing: AppTheme.spacing4.w,
          runSpacing: AppTheme.spacing4.h,
          children: [
            DetailActionButton(
              label: 'Add to Cart',
              background: primary,
              textColor: colors.black,
              borderColor: isDark ? colors.white : colors.black,
              colors: colors,
            ),
            DetailActionButton(
              label: 'Wishlist',
              background: isDark ? colors.zinc900 : colors.white,
              textColor: isDark ? colors.white : colors.black,
              borderColor: isDark ? colors.white : colors.black,
              colors: colors,
            ),
          ],
        ),
      ],
    );
  }
}
