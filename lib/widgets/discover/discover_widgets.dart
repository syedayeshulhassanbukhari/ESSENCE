import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../models/fragella_fragrance.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';

class DiscoverStyle {
  static const Color primary = Color(0xFFFAC638);
  static const Color bgLight = Color(0xFFF8F8F5);
  static const Color bgDark = Color(0xFF231E0F);
  static const Color neoLime = Color(0xFFBEF264);
  static const Color neoOrange = Color(0xFFFB923C);
  static const Color neoPink = Color(0xFFF472B6);
  static const Color neoBlue = Color(0xFF60A5FA);
}

class DiscoverNavBar extends SliverPersistentHeaderDelegate {
  DiscoverNavBar({
    required this.height,
    required this.isSmall,
    required this.isDark,
  });

  final double height;
  final bool isSmall;
  final bool isDark;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final colors = context.watch<ThemeProvider>().colors;
    return SizedBox(
      height: height,
      child: Container(
        color: isDark ? DiscoverStyle.bgDark : DiscoverStyle.bgLight,
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.spacing6.w,
          vertical: AppTheme.spacing4.h,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.spacing2.w,
                vertical: AppTheme.spacing2.h,
              ),
              decoration: BoxDecoration(
                color: DiscoverStyle.primary,
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
                'SCENT.LAB',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
              ),
            ),
            SizedBox(width: AppTheme.spacing6.w),
            if (!isSmall) ...[
              const _NavItem(label: 'Discovery', hasDropdown: true),
              const _NavItem(label: 'Marketplace', hasDropdown: true),
              const _NavItem(label: 'Archive', hasDropdown: false),
            ],
            const Spacer(),
            const _IconButton(icon: Icons.search, isPrimary: false),
            SizedBox(width: AppTheme.spacing2.w),
            const _IconButton(icon: Icons.shopping_bag, isPrimary: true),
            if (isSmall) ...[
              SizedBox(width: AppTheme.spacing2.w),
              const _IconButton(icon: Icons.menu, isPrimary: false),
            ],
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant DiscoverNavBar oldDelegate) {
    return oldDelegate.height != height ||
        oldDelegate.isSmall != isSmall ||
        oldDelegate.isDark != isDark;
  }
}

class DiscoverFilterBar extends SliverPersistentHeaderDelegate {
  DiscoverFilterBar({
    required this.height,
    required this.isSmall,
    required this.isDark,
    required this.filters,
    required this.onSearch,
    required this.searchController,
  });

  final double height;
  final bool isSmall;
  final bool isDark;
  final List<Map<String, String>> filters;
  final ValueChanged<String> onSearch;
  final TextEditingController searchController;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final colors = context.watch<ThemeProvider>().colors;
    return SizedBox(
      height: height,
      child: Container(
        color: isDark ? DiscoverStyle.bgDark : DiscoverStyle.bgLight,
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.spacing6.w,
          vertical: AppTheme.spacing2.h,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colors.black,
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
                            label: filter['label']!,
                            colorToken: filter['color']!,
                            onTap: () => onSearch(filter['label']!),
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
                onSubmitted: onSearch,
                decoration: InputDecoration(
                  hintText: 'SEARCH',
                  filled: true,
                  fillColor: colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing2.w,
                    vertical: AppTheme.spacing2.h,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: colors.black,
                      width: AppTheme.borderWidth,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: colors.black,
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
                    value: 'PRICE: LOW-HIGH',
                    child: Text('PRICE: LOW-HIGH'),
                  ),
                  DropdownMenuItem(
                    value: 'PRICE: HIGH-LOW',
                    child: Text('PRICE: HIGH-LOW'),
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
        oldDelegate.filters != filters ||
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
  final String colorToken;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    Color background;
    switch (colorToken) {
      case 'lime':
        background = DiscoverStyle.neoLime;
        break;
      case 'orange':
        background = DiscoverStyle.neoOrange;
        break;
      case 'pink':
        background = DiscoverStyle.neoPink;
        break;
      default:
        background = colors.white;
    }

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

  final FragellaFragrance fragrance;

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final background = _cardBackground(colors, fragrance);
    final badge = _badgeFor(fragrance);
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
            color: colors.black,
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
                    color: colors.black,
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
                        color: colors.black,
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
                color: colors.white,
                border: Border(
                  top: BorderSide(
                    color: colors.black,
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
                                ),
                      ),
                      Text(
                        fragrance.price.isNotEmpty
                            ? '\$${fragrance.price}'
                            : '—',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
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
                      color: DiscoverStyle.primary,
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

  Color _cardBackground(ThemeColors colors, FragellaFragrance fragrance) {
    final accords = fragrance.mainAccords.map((e) => e.toLowerCase()).toList();
    if (accords.any((value) => value.contains('woody'))) {
      return DiscoverStyle.neoLime;
    }
    if (accords.any((value) => value.contains('citrus'))) {
      return DiscoverStyle.neoOrange;
    }
    if (accords.any((value) => value.contains('floral'))) {
      return DiscoverStyle.neoPink;
    }
    if (accords.any((value) => value.contains('aquatic')) ||
        accords.any((value) => value.contains('fresh'))) {
      return DiscoverStyle.neoBlue;
    }
    if (fragrance.gender.toLowerCase().contains('men')) {
      return colors.black;
    }
    return colors.white;
  }

  _BadgeStyle _badgeFor(FragellaFragrance fragrance) {
    final popularity = fragrance.popularity.toLowerCase();
    if (popularity.contains('very high')) {
      return const _BadgeStyle('BESTSELLER', true);
    }
    if (fragrance.confidence.toLowerCase() == 'high') {
      return const _BadgeStyle('HOT', false);
    }
    if (fragrance.year.isNotEmpty) {
      return const _BadgeStyle('NEW', false);
    }
    return const _BadgeStyle('DISCOVER', true);
  }
}

class _BadgeStyle {
  const _BadgeStyle(this.label, this.isLight);

  final String label;
  final bool isLight;
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
              color: colors.white,
              width: AppTheme.borderWidth,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: colors.white,
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
        color: DiscoverStyle.primary,
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
                color: DiscoverStyle.primary,
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
                color: DiscoverStyle.primary,
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

class _NavItem extends StatelessWidget {
  const _NavItem({required this.label, required this.hasDropdown});

  final String label;
  final bool hasDropdown;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: AppTheme.spacing4.w),
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          if (hasDropdown) ...[
            SizedBox(width: AppTheme.spacing2.w),
            const Icon(Icons.expand_more, size: 18),
          ],
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.isPrimary});

  final IconData icon;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing2.w),
      decoration: BoxDecoration(
        color: isPrimary ? DiscoverStyle.primary : colors.white,
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
      child: Icon(icon, color: colors.black, size: 20.sp),
    );
  }
}
