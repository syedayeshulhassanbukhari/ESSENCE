import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';

class PerfumeFooterSection extends StatelessWidget {
  const PerfumeFooterSection({
    super.key,
    required this.isDark,
    required this.colors,
  });

  final bool isDark;
  final ThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing6.w),
      decoration: BoxDecoration(
        color: isDark ? colors.black : colors.white,
        border: Border.all(
          color: isDark ? colors.white : colors.black,
          width: AppTheme.borderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _footerBrand(context)),
                    Expanded(child: _footerInfo(context)),
                    Expanded(child: _footerSocial(context)),
                    Expanded(child: _footerSubscribe(context)),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _footerBrand(context),
                  SizedBox(height: AppTheme.spacing4.h),
                  _footerInfo(context),
                  SizedBox(height: AppTheme.spacing4.h),
                  _footerSocial(context),
                  SizedBox(height: AppTheme.spacing4.h),
                  _footerSubscribe(context),
                ],
              );
            },
          ),
          SizedBox(height: AppTheme.spacing6.h),
          Center(
            child: Text(
              '(c) 2024 AURA SCENTS LABORATORY. ALL RIGHTS RESERVED.',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colors.gray400,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _footerBrand(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AURA SCENTS',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                color: isDark ? colors.white : colors.black,
              ),
        ),
        SizedBox(height: AppTheme.spacing2.h),
        Text(
          'Neo-Brutalist olfactive experiments based in Berlin.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.gray400,
              ),
        ),
      ],
    );
  }

  Widget _footerInfo(BuildContext context) {
    return _footerLinks(
      context,
      title: 'Info',
      links: const ['Shipping', 'Returns', 'Stockists'],
    );
  }

  Widget _footerSocial(BuildContext context) {
    return _footerLinks(
      context,
      title: 'Social',
      links: const ['Instagram', 'TikTok', 'Vimeo'],
    );
  }

  Widget _footerSubscribe(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subscribe',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: isDark ? colors.white : colors.black,
              ),
        ),
        SizedBox(height: AppTheme.spacing2.h),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'EMAIL',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: isDark ? colors.white : colors.black,
                      width: AppTheme.borderWidth,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: isDark ? colors.white : colors.black,
                      width: AppTheme.borderWidth,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing4.w,
                    vertical: AppTheme.spacing4.h,
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.spacing4.w,
                vertical: AppTheme.spacing4.h,
              ),
              decoration: BoxDecoration(
                color: isDark ? colors.white : colors.black,
                border: Border.all(
                  color: isDark ? colors.white : colors.black,
                  width: AppTheme.borderWidth,
                ),
              ),
              child: Icon(
                Icons.arrow_forward,
                color: isDark ? colors.black : colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _footerLinks(
    BuildContext context, {
    required String title,
    required List<String> links,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: isDark ? colors.white : colors.black,
              ),
        ),
        SizedBox(height: AppTheme.spacing2.h),
        ...links.map(
          (link) => Padding(
            padding: EdgeInsets.only(bottom: AppTheme.spacing2.h),
            child: Text(
              link,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? colors.white : colors.black,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
