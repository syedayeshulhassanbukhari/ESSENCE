import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';
import 'detail_action_button.dart';

class PerfumeReviewsSection extends StatelessWidget {
  const PerfumeReviewsSection({
    super.key,
    required this.rating,
    required this.isDark,
    required this.colors,
    required this.primary,
  });

  final String rating;
  final bool isDark;
  final ThemeColors colors;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'User Reviews',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                  ),
            ),
            if (MediaQuery.sizeOf(context).width > 640)
              Text(
                '$rating / 5.0',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
          ],
        ),
        SizedBox(height: AppTheme.spacing4.h),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            final crossAxisCount = isWide ? 3 : 2;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: AppTheme.spacing4.w,
                mainAxisSpacing: AppTheme.spacing4.h,
                mainAxisExtent: 210.h,
              ),
              itemCount: 3,
              itemBuilder: (context, index) {
                return _ReviewCard(
                  index: index,
                  isDark: isDark,
                  colors: colors,
                  primary: primary,
                );
              },
            );
          },
        ),
        SizedBox(height: AppTheme.spacing4.h),
        Center(
          child: DetailActionButton(
            label: 'Load More Reviews',
            background: isDark ? colors.white : colors.black,
            textColor: isDark ? colors.black : colors.white,
            borderColor: isDark ? colors.white : colors.black,
            colors: colors,
          ),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.index,
    required this.isDark,
    required this.colors,
    required this.primary,
  });

  final int index;
  final bool isDark;
  final ThemeColors colors;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final backgrounds = [colors.white, colors.white, primary];
    final background = backgrounds[index % backgrounds.length];

    return Container(
      padding: EdgeInsets.all(AppTheme.spacing6.w),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(
          color: isDark ? colors.white : colors.black,
          width: AppTheme.borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.black,
            offset: const Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index == 4 ? Icons.star_half : Icons.star,
                size: 18.sp,
                color: colors.black,
              ),
            ),
          ),
          SizedBox(height: AppTheme.spacing4.h),
          Text(
            _reviewText(index).toUpperCase(),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                ),
          ),
          const Spacer(),
          Divider(
            color: isDark ? colors.white : colors.black,
            thickness: 2,
          ),
          SizedBox(height: AppTheme.spacing2.h),
          Text(
            _reviewAuthor(index),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          Text(
            'Verified Buyer',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.gray400,
                ),
          ),
        ],
      ),
    );
  }

  String _reviewText(int index) {
    const items = [
      'Smells like a lightning storm in a concrete jungle. Obsessed.',
      'Unusual but addictive. Definitely gets people asking what I\'m wearing.',
      'The longevity is insane. Smells even better on a leather jacket.',
    ];
    return items[index % items.length];
  }

  String _reviewAuthor(int index) {
    const items = ['@VEX_DESIGNS', '@NOISE_COLLECTIVE', '@BRUTAL_MARCO'];
    return items[index % items.length];
  }
}
