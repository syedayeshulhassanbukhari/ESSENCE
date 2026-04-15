import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../models/discover_color_token.dart';
import '../../models/discover_filter.dart';
import '../../models/fragella_fragrance.dart';
import '../../providers/theme_provider.dart';
import '../../services/discover_presentation_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/discover_palette.dart';

class DiscoverFilterBar extends SliverPersistentHeaderDelegate {
  DiscoverFilterBar({
    required this.height,
    required this.isSmall,
    required this.isDark,
    required this.colors,
    required this.filters,
    required this.onSearch,
    required this.onSearchChanged,
    required this.searchController,
  });

  final double height;
  final bool isSmall;
  final bool isDark;
  final ThemeColors colors;
  final List<DiscoverFilter> filters;
  final ValueChanged<String> onSearch;
  final ValueChanged<String> onSearchChanged;
  final TextEditingController searchController;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(
      height: height,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.spacing6.w,
          vertical: AppTheme.spacing2.h,
        ),
        decoration: BoxDecoration(
          color: isDark ? colors.backgroundDark : DiscoverPalette.bgLight,
          border: Border(
            bottom: BorderSide(
              color: isDark ? colors.primaryYellow : colors.black,
              width: AppTheme.borderWidth,
            ),
          ),
        ),
        child: Row(
          children: [
            Text(
              'Filter By:',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            SizedBox(width: AppTheme.spacing2.w),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: filters
                      .map(
                        (filter) => Padding(
                          padding: EdgeInsets.only(right: AppTheme.spacing2.w),
                          child: _FilterChip(
                            label: filter.label,
                            colorToken: filter.colorToken,
                            onTap: () => onSearch(filter.label),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            SizedBox(width: AppTheme.spacing2.w),
            SizedBox(
              width: isSmall ? 160.w : 220.w,
              child: TextField(
                controller: searchController,
                textInputAction: TextInputAction.search,
                onChanged: onSearchChanged,
                onSubmitted: onSearch,
                decoration: InputDecoration(
                  hintText: 'SEARCH',
                  filled: true,
                  fillColor: isDark ? colors.zinc900 : colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing2.w,
                    vertical: AppTheme.spacing2.h,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: isDark ? colors.primaryYellow : colors.black,
                      width: AppTheme.borderWidth,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: isDark ? colors.primaryYellow : colors.black,
                      width: AppTheme.borderWidth,
                    ),
                  ),
                ),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            SizedBox(width: AppTheme.spacing2.w),
            if (!isSmall)
              Text(
                'Sort:',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
            SizedBox(width: AppTheme.spacing2.w),
            Container(
              decoration: BoxDecoration(
                color: colors.white,
                border: Border.all(
                  color: colors.black,
                  width: AppTheme.borderWidth,
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing2.w),
              child: DropdownButton<String>(
                value: 'NEWEST',
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(value: 'NEWEST', child: Text('NEWEST')),
                  DropdownMenuItem(
                    value: 'A-Z',
                    child: Text('A-Z'),
                  ),
                  DropdownMenuItem(
                    value: 'MOST POPULAR',
                    child: Text('MOST POPULAR'),
                  ),
                ],
                onChanged: (_) {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant DiscoverFilterBar oldDelegate) {
    return oldDelegate.height != height ||
        oldDelegate.isSmall != isSmall ||
        oldDelegate.isDark != isDark ||
        oldDelegate.colors != colors ||
        oldDelegate.filters != filters ||
        oldDelegate.onSearchChanged != onSearchChanged ||
        oldDelegate.searchController != searchController;
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.colorToken,
    required this.onTap,
  });

  final String label;
  final DiscoverColorToken colorToken;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final background = DiscoverPalette.colorForToken(colors, colorToken);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.spacing4.w,
          vertical: AppTheme.spacing2.h,
        ),
        decoration: BoxDecoration(
          color: background,
          border: Border.all(
            color: colors.black,
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
        child: Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
      ),
    );
  }
}

class DiscoverCard extends StatelessWidget {
  const DiscoverCard({required this.fragrance});

  static const DiscoverPresentationService _presentationService =
      DiscoverPresentationService();

  final FragellaFragrance fragrance;

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final presentation = _presentationService.buildCardPresentation(fragrance);
    final background = DiscoverPalette.colorForToken(
      colors,
      presentation.backgroundToken,
    );
    final badge = presentation.badge;
    final isDarkCard = background == colors.black;
    final cardBorder = isDarkCard ? colors.white : colors.black;
    final badgeBg = badge.isLight ? colors.white : colors.black;
    final badgeText = badge.isLight ? colors.black : colors.white;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          '/individualDetails',
          arguments: fragrance,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: background,
          border: Border.all(
            color: cardBorder,
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
            Container(
              padding: EdgeInsets.all(AppTheme.spacing4.w),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: cardBorder,
                    width: AppTheme.borderWidth,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      fragrance.name.replaceAll(' ', '\n'),
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1,
                                color: isDarkCard ? colors.white : colors.black,
                              ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing2.w,
                      vertical: AppTheme.spacing2.h,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      border: Border.all(
                        color: cardBorder,
                        width: AppTheme.borderWidth,
                      ),
                    ),
                    child: Text(
                      badge.label,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: badgeText,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white.withOpacity(0.3),
                padding: EdgeInsets.all(AppTheme.spacing4.w),
                child: Center(
                  child: fragrance.imageUrl.isNotEmpty
                      ? Image.network(
                          fragrance.imageUrl,
                          fit: BoxFit.contain,
                        )
                      : const Icon(Icons.local_florist, size: 48),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(AppTheme.spacing4.w),
              decoration: BoxDecoration(
                color: isDarkCard ? colors.zinc900 : colors.white,
                border: Border(
                  top: BorderSide(
                    color: cardBorder,
                    width: AppTheme.borderWidth,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        fragrance.oilType.isNotEmpty
                            ? fragrance.oilType.toUpperCase()
                            : 'EDP',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: isDarkCard ? colors.white : colors.black,
                                ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.spacing4.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: AppTheme.spacing4.h,
                    ),
                    decoration: BoxDecoration(
                      color: DiscoverPalette.primary,
                      border: Border.all(
                        color: colors.black,
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
                    child: Center(
                      child: Text(
                        'View Details'.toUpperCase(),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DiscoverFooter extends StatelessWidget {
  const DiscoverFooter({required this.isSmall});

  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    return Container(
      color: colors.black,
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacing6.w,
        vertical: AppTheme.spacing6.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Join the Lab',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: colors.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
          SizedBox(height: AppTheme.spacing4.h),
          Text(
            'Drop your email for exclusive discovery kit drops and limited editions.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: AppTheme.spacing4.h),
          isSmall
              ? Column(
                  children: [
                    const _FooterInputRow(isStacked: true),
                    SizedBox(height: AppTheme.spacing6.h),
                    const _FooterLinks(isSmall: true),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(child: _FooterInputRow(isStacked: false)),
                    SizedBox(width: AppTheme.spacing8.w),
                    const Expanded(child: _FooterExplore()),
                    SizedBox(width: AppTheme.spacing6.w),
                    const Expanded(child: _FooterConnect()),
                  ],
                ),
          SizedBox(height: AppTheme.spacing6.h),
          Text(
            '©2024 SCENT.LAB ALL RIGHTS RESERVED. DESIGNED FOR THE BOLD.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.gray400,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _FooterInputRow extends StatelessWidget {
  const _FooterInputRow({required this.isStacked});

  final bool isStacked;

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final brightness = Theme.of(context).brightness;
    final borderColor =
        brightness == Brightness.dark ? colors.primaryYellow : colors.white;
    final input = Expanded(
      child: TextField(
        decoration: InputDecoration(
          hintText: 'YOUR@EMAIL.COM',
          hintStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colors.gray400,
                fontWeight: FontWeight.w700,
              ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: borderColor,
              width: AppTheme.borderWidth,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: borderColor,
              width: AppTheme.borderWidth,
            ),
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppTheme.spacing4.w,
            vertical: AppTheme.spacing4.h,
          ),
        ),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colors.white,
              fontWeight: FontWeight.w700,
            ),
      ),
    );

    final button = Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacing6.w,
        vertical: AppTheme.spacing4.h,
      ),
      decoration: BoxDecoration(
        color: DiscoverPalette.primary,
        border: Border.all(
          color: colors.white,
          width: AppTheme.borderWidth,
        ),
      ),
      child: Text(
        'Join'.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colors.black,
              fontWeight: FontWeight.w900,
            ),
      ),
    );

    if (isStacked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          input,
          SizedBox(height: AppTheme.spacing4.h),
          button,
        ],
      );
    }

    return Row(
      children: [
        input,
        button,
      ],
    );
  }
}

class _FooterExplore extends StatelessWidget {
  const _FooterExplore();

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Explore',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: DiscoverPalette.primary,
                fontWeight: FontWeight.w900,
              ),
        ),
        SizedBox(height: AppTheme.spacing4.h),
        ...['THE COLLECTION', 'INGREDIENT GLOSSARY', 'MARKETPLACE', 'LAB JOURNALS']
            .map(
              (item) => Padding(
                padding: EdgeInsets.only(bottom: AppTheme.spacing2.h),
                child: Text(
                  item,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),
      ],
    );
  }
}

class _FooterConnect extends StatelessWidget {
  const _FooterConnect();

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Connect',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: DiscoverPalette.primary,
                fontWeight: FontWeight.w900,
              ),
        ),
        SizedBox(height: AppTheme.spacing4.h),
        Row(
          children: ['INSTA', 'TWTR', 'TIKTK']
              .map(
                (label) => Padding(
                  padding: EdgeInsets.only(right: AppTheme.spacing2.w),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing4.w,
                      vertical: AppTheme.spacing2.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colors.white,
                        width: AppTheme.borderWidth,
                      ),
                    ),
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _FooterLinks extends StatelessWidget {
  const _FooterLinks({required this.isSmall});

  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    return isSmall
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _FooterExplore(),
              SizedBox(height: AppTheme.spacing6.h),
              const _FooterConnect(),
            ],
          )
        : const SizedBox.shrink();
  }
}
