import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/responsive_provider.dart';
import '../theme/app_theme.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  static const Color _primary = Color(0xFFFAC638);
  static const Color _bgLight = Color(0xFFF8F8F5);
  static const Color _bgDark = Color(0xFF231E0F);
  static const Color _neoLime = Color(0xFFBEF264);
  static const Color _neoOrange = Color(0xFFFB923C);
  static const Color _neoPink = Color(0xFFF472B6);
  static const Color _neoBlue = Color(0xFF60A5FA);

  static const List<Map<String, String>> _filters = [
    {'label': 'Woody', 'color': 'lime'},
    {'label': 'Floral', 'color': 'white'},
    {'label': 'Citrus', 'color': 'orange'},
    {'label': 'Oud', 'color': 'white'},
    {'label': 'Spicy', 'color': 'pink'},
  ];

  static const List<Map<String, String>> _cards = [
    {
      'name': 'Obsidian Night',
      'badge': 'NEW',
      'size': '50ML',
      'price': '\$145.00',
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDrT_DcguIdU4yisX95q24doQKBukIM80oRn7K4mJoch6CY5_MnmDJoeL2o1P-ImHMKHTT8WXu-u4FoQNk77QBDOtoOdoa4qPNPd35dFXwEKgA6we4J4f5oMEWHvrlqRrxY1Mzz2dqXcdaOIQWKW4jFXnTwVT0k56ZTTwouI3svZdCtyi6VwS1_n-Sszyrfr12yIBV3thI1geTRnJjAXCBIVvv9XMQx5mohR0dz-Kh7ESBmWJCPZO7rfLBr4VhAIfDAqhn6sqUeI7Q',
      'theme': 'lime',
      'badgeStyle': 'dark',
    },
    {
      'name': 'Solar Flare',
      'badge': 'BESTSELLER',
      'size': '100ML',
      'price': '\$210.00',
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCL690zBM48FV7fRaP7YrMq2BgTHYdjtsKsPf8cC76eREHtQf8QPPb7_YQvT7xx2WruOvxSdhAI9bes0_tWvU4T4Du5TVDvanrV0sgp_Y--d6c4nOMQ5wCaE1NpTLEqmkZgrmvwoQPT9mZFu44Bxs3xBc1_HJU5unP49Sjwv9uLw548ONolF1fCeSnZWUctFnVVvQ2_pCGcaFo9onGp2-kwJDUKh5mTev33fVcR-FG3ebnCqXKRyq9i5cA4JY6fkoFJQHH39CKiTXk',
      'theme': 'orange',
      'badgeStyle': 'light',
    },
    {
      'name': 'Velvet Dusk',
      'badge': 'LIMITED',
      'size': '50ML',
      'price': '\$185.00',
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDkV9qfEmufEJOK0Z836kmWz5uuSFmI9dLkuQKn3nxG70TSEU6uNdqNpZqbyou7YLIbfD9BvbuadxQ1m-SuY53_t7IwwPcrFlClcY92fyhi4ptQcJE2cS9O81ytCsccNNLSGW-piZi1HuQ5z8aH52m9MSSWhcRTbsD0nYgyJTLJ1-ORjw1rnKu87jE8AlGf5SbAjlrSgvUfigWiF8kYi3rQUFCagkjmF9lO-SdyyfP_vC5vxMjrUulJrfTGeyJTpjmLD16e_iNjPxg',
      'theme': 'pink',
      'badgeStyle': 'dark',
    },
    {
      'name': 'Arctic Mist',
      'badge': 'REFRESH',
      'size': '30ML',
      'price': '\$95.00',
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA_movqrFX0d4RhOQP0KY86mcm7dZi1HTWyrPQKuNfhYqqvgxKPlteiXnPOpL99T_GjosRiGLUwxg3rCn6Zl0Zdy5Ydq3mn3ER5R6Cz22Iu1TImqf6xZvQFXV68E2XcGdwFAGRyKyIkhubu16pQSrpSpjeMuxUi61dHy-jHe6YnvZdWbbGNDllY_zlx6j2gTFrzPW_rheMat3CUzywZy0XunFXFs5vvuj3KAz4am1ksa_M9JCdE-rg6-IPiY8XHGMiRY0Pbfh1BWVM',
      'theme': 'blue',
      'badgeStyle': 'light',
    },
    {
      'name': 'Concrete Rose',
      'badge': 'NEW',
      'size': '50ML',
      'price': '\$160.00',
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuC6QnBlHJIEpJK0XS4LOoQKCLPs1aXfKPKRNnZe5ckxRruSvK_vEsEMK2hm6JlW0GN7UNIpvLu5YckMWfV3Srvav2Z1zD-75WzsMe_eEyJYqQwpyRkWcODFdmav5Ig-601tfSeFUl_gsryHSXDkY2j8nwIg-q9l1cTI6jiDcFG2TQposRiftRRa66X-kCxw1OeLa3T9cjJnOPuEraHxlbf4QlKUgImspU34L-qQd41dNBTwPmJD6Lucon-GFh4x6qXQJKe8ZkDCjcE',
      'theme': 'white',
      'badgeStyle': 'dark',
    },
    {
      'name': 'Neon Amber',
      'badge': 'HOT',
      'size': '100ML',
      'price': '\$240.00',
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCvCqQclQFk9gEm-tdwOSqbwdPWc797yioFcoKzLnOqAKk0DoJG-4c0bDFKeZiHT2odR9CPPODYWAQBRQXD48FadQHHFjxVBZyGx1BfkFY3q9SqnqOeOuXGPmEaDzL6Ieakb7pWwuByNlS7ewo2bkflFySy7vC8bv1P89KN1h-70io2N8AIFTLcKr7zPHoAbenbym3wj9EfgelrNEcXkzjMntWsWR56VVSeF1Gx8vYaKQH_WJzgfiINixsdnnV2FOQOp4mUqZTNMJQ',
      'theme': 'black',
      'badgeStyle': 'light',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final responsive = context.watch<ResponsiveProvider>();
    final isSmall = responsive.isSmall;
    final isMedium = responsive.isMedium;
    final gridColumns = isSmall ? 1 : (isMedium ? 2 : 3);

    return Scaffold(
      backgroundColor: isDark ? _bgDark : _bgLight,
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _DiscoverNavBar(
              height: isSmall ? 72.h : 84.h,
              isSmall: isSmall,
              isDark: isDark,
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.spacing6.w,
                vertical: AppTheme.spacing6.h,
              ),
              decoration: BoxDecoration(
                color: _primary.withValues(alpha: 0.1),
                border: const Border(
                  bottom: BorderSide(
                    color: AppTheme.black,
                    width: AppTheme.borderWidth,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The Discovery Lab',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: isSmall ? 48.sp : (isMedium ? 72.sp : 96.sp),
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.5,
                        ),
                  ),
                  SizedBox(height: AppTheme.spacing4.h),
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: AppTheme.black,
                          width: AppTheme.borderWidth,
                        ),
                      ),
                    ),
                    padding: EdgeInsets.only(left: AppTheme.spacing4.w),
                    child: Text(
                      'BRUTALIST SCENTS FOR THE BOLD. EXPLORE OUR CURATED GRID OF OLFACTORY ART PIECES.',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: isSmall ? 16.sp : 20.sp,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _DiscoverFilterBar(
              height: isSmall ? 72.h : 64.h,
              isSmall: isSmall,
              isDark: isDark,
              filters: _filters,
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.spacing6.w,
              vertical: AppTheme.spacing6.h,
            ),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridColumns,
                mainAxisSpacing: AppTheme.spacing6.h,
                crossAxisSpacing: AppTheme.spacing6.w,
                mainAxisExtent: isSmall ? 520.h : 560.h,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final card = _cards[index];
                  return _DiscoverCard(
                    name: card['name']!,
                    badge: card['badge']!,
                    size: card['size']!,
                    price: card['price']!,
                    imageUrl: card['imageUrl']!,
                    theme: card['theme']!,
                    badgeStyle: card['badgeStyle']!,
                  );
                },
                childCount: _cards.length,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _DiscoverFooter(isSmall: isSmall),
          ),
        ],
      ),
    );
  }
}

class _DiscoverNavBar extends SliverPersistentHeaderDelegate {
  _DiscoverNavBar({
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
    return Container(
      color: isDark ? DiscoverScreen._bgDark : DiscoverScreen._bgLight,
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
              color: DiscoverScreen._primary,
              border: Border.all(
                color: AppTheme.black,
                width: AppTheme.borderWidth,
              ),
              boxShadow: const [
                BoxShadow(
                  color: AppTheme.black,
                  offset: Offset(4, 4),
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
            _NavItem(label: 'Discovery', hasDropdown: true),
            _NavItem(label: 'Marketplace', hasDropdown: true),
            _NavItem(label: 'Archive', hasDropdown: false),
          ],
          const Spacer(),
          _IconButton(icon: Icons.search, isPrimary: false),
          SizedBox(width: AppTheme.spacing2.w),
          _IconButton(icon: Icons.shopping_bag, isPrimary: true),
          if (isSmall) ...[
            SizedBox(width: AppTheme.spacing2.w),
            _IconButton(icon: Icons.menu, isPrimary: false),
          ],
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _DiscoverNavBar oldDelegate) {
    return oldDelegate.height != height ||
        oldDelegate.isSmall != isSmall ||
        oldDelegate.isDark != isDark;
  }
}

class _DiscoverFilterBar extends SliverPersistentHeaderDelegate {
  _DiscoverFilterBar({
    required this.height,
    required this.isSmall,
    required this.isDark,
    required this.filters,
  });

  final double height;
  final bool isSmall;
  final bool isDark;
  final List<Map<String, String>> filters;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: isDark ? DiscoverScreen._bgDark : DiscoverScreen._bgLight,
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacing6.w,
        vertical: AppTheme.spacing2.h,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.black,
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
                        ),
                      ),
                    )
                    .toList(),
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
              color: AppTheme.white,
              border: Border.all(
                color: AppTheme.black,
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
    );
  }

  @override
  bool shouldRebuild(covariant _DiscoverFilterBar oldDelegate) {
    return oldDelegate.height != height ||
        oldDelegate.isSmall != isSmall ||
        oldDelegate.isDark != isDark ||
        oldDelegate.filters != filters;
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.colorToken});

  final String label;
  final String colorToken;

  @override
  Widget build(BuildContext context) {
    Color background;
    switch (colorToken) {
      case 'lime':
        background = DiscoverScreen._neoLime;
        break;
      case 'orange':
        background = DiscoverScreen._neoOrange;
        break;
      case 'pink':
        background = DiscoverScreen._neoPink;
        break;
      default:
        background = AppTheme.white;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacing4.w,
        vertical: AppTheme.spacing2.h,
      ),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(
          color: AppTheme.black,
          width: AppTheme.borderWidth,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.black,
            offset: Offset(4, 4),
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
    );
  }
}

class _DiscoverCard extends StatelessWidget {
  const _DiscoverCard({
    required this.name,
    required this.badge,
    required this.size,
    required this.price,
    required this.imageUrl,
    required this.theme,
    required this.badgeStyle,
  });

  final String name;
  final String badge;
  final String size;
  final String price;
  final String imageUrl;
  final String theme;
  final String badgeStyle;

  @override
  Widget build(BuildContext context) {
    final background = _cardBackground(theme);
    final badgeBg = badgeStyle == 'dark' ? AppTheme.black : AppTheme.white;
    final badgeText = badgeStyle == 'dark' ? AppTheme.white : AppTheme.black;

    return Container(
      decoration: BoxDecoration(
        color: background,
        border: Border.all(
          color: AppTheme.black,
          width: AppTheme.borderWidth,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.black,
            offset: Offset(8, 8),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(AppTheme.spacing4.w),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.black,
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
                    name.replaceAll(' ', '\n'),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
                      color: AppTheme.black,
                      width: AppTheme.borderWidth,
                    ),
                  ),
                  child: Text(
                    badge,
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
              color: Colors.white.withValues(alpha: 0.3),
              padding: EdgeInsets.all(AppTheme.spacing4.w),
              child: Center(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(AppTheme.spacing4.w),
            decoration: const BoxDecoration(
              color: AppTheme.white,
              border: Border(
                top: BorderSide(
                  color: AppTheme.black,
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
                      size,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    Text(
                      price,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                    color: DiscoverScreen._primary,
                    border: Border.all(
                      color: AppTheme.black,
                      width: AppTheme.borderWidth,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: AppTheme.black,
                        offset: Offset(4, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'View Details'.toUpperCase(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
    );
  }

  Color _cardBackground(String theme) {
    switch (theme) {
      case 'lime':
        return DiscoverScreen._neoLime;
      case 'orange':
        return DiscoverScreen._neoOrange;
      case 'pink':
        return DiscoverScreen._neoPink;
      case 'blue':
        return DiscoverScreen._neoBlue;
      case 'black':
        return AppTheme.black;
      default:
        return AppTheme.white;
    }
  }
}

class _DiscoverFooter extends StatelessWidget {
  const _DiscoverFooter({required this.isSmall});

  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.black,
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
                  color: AppTheme.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
          SizedBox(height: AppTheme.spacing4.h),
          Text(
            'Drop your email for exclusive discovery kit drops and limited editions.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: AppTheme.spacing4.h),
          isSmall
              ? Column(
                  children: [
                    _FooterInputRow(isStacked: true),
                    SizedBox(height: AppTheme.spacing6.h),
                    _FooterLinks(isSmall: true),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _FooterInputRow(isStacked: false)),
                    SizedBox(width: AppTheme.spacing8.w),
                    Expanded(child: _FooterExplore()),
                    SizedBox(width: AppTheme.spacing6.w),
                    Expanded(child: _FooterConnect()),
                  ],
                ),
          SizedBox(height: AppTheme.spacing6.h),
          Text(
            '©2024 SCENT.LAB ALL RIGHTS RESERVED. DESIGNED FOR THE BOLD.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.gray400,
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
    final input = Expanded(
      child: TextField(
        decoration: InputDecoration(
          hintText: 'YOUR@EMAIL.COM',
          hintStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.gray400,
                fontWeight: FontWeight.w700,
              ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: AppTheme.white,
              width: AppTheme.borderWidth,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: AppTheme.white,
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
              color: AppTheme.white,
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
        color: DiscoverScreen._primary,
        border: Border.all(
          color: AppTheme.white,
          width: AppTheme.borderWidth,
        ),
      ),
      child: Text(
        'Join'.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppTheme.black,
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
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Explore',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: DiscoverScreen._primary,
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
                        color: AppTheme.white,
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
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Connect',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: DiscoverScreen._primary,
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
                        color: AppTheme.white,
                        width: AppTheme.borderWidth,
                      ),
                    ),
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.white,
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
              _FooterExplore(),
              SizedBox(height: AppTheme.spacing6.h),
              _FooterConnect(),
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
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing2.w),
      decoration: BoxDecoration(
        color: isPrimary ? DiscoverScreen._primary : AppTheme.white,
        border: Border.all(
          color: AppTheme.black,
          width: AppTheme.borderWidth,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.black,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Icon(icon, color: AppTheme.black, size: 20.sp),
    );
  }
}