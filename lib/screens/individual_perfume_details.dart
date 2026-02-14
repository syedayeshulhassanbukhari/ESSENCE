import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../models/fragella_fragrance.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class IndividualPerfumeDetails extends StatelessWidget {
  const IndividualPerfumeDetails({super.key, this.fragrance});

  final FragellaFragrance? fragrance;

  static const Color _primary = Color(0xFFFAC638);
  static const Color _bgLight = Color(0xFFF8F8F5);
  static const Color _bgDark = Color(0xFF231E0F);
  static const Color _accentCyan = Color(0xFF00F0FF);

  @override
  Widget build(BuildContext context) {
    final data = fragrance ??
        ModalRoute.of(context)?.settings.arguments as FragellaFragrance?;

    if (data == null) {
      return Scaffold(
        backgroundColor: _bgLight,
        body: Center(
          child: Text(
            'No perfume selected.',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      );
    }

    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final colors = context.watch<ThemeProvider>().colors;
    final nameParts = _splitName(data.name);
    final notes = _resolveNotes(data);

    return Scaffold(
      backgroundColor: isDark ? _bgDark : _bgLight,
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _DetailsHeader(isDark: isDark, colors: colors),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.spacing6.w,
              vertical: AppTheme.spacing6.h,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  _buildTopSection(context, data, nameParts, isDark, colors),
                  SizedBox(height: AppTheme.spacing8.h),
                  _buildNotesSection(context, notes, isDark, colors),
                  SizedBox(height: AppTheme.spacing8.h),
                  _buildReviewsSection(context, data, isDark, colors),
                  SizedBox(height: AppTheme.spacing8.h),
                  _buildCtaSection(context, isDark, colors),
                  SizedBox(height: AppTheme.spacing8.h),
                  _buildFooter(context, isDark, colors),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSection(
    BuildContext context,
    FragellaFragrance data,
    List<String> nameParts,
    bool isDark,
    ThemeColors colors,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final image = _buildImageCard(data.imageUrl, isDark, colors);
        final detail = _buildDetailCard(context, data, nameParts, isDark, colors);

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

  Widget _buildImageCard(String imageUrl, bool isDark, ThemeColors colors) {
    return Container(
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
        aspectRatio: 1,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.05),
              colorBlendMode: BlendMode.darken,
            ),
            Container(
              color: Colors.black.withOpacity(0.08),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(
    BuildContext context,
    FragellaFragrance data,
    List<String> nameParts,
    bool isDark,
    ThemeColors colors,
  ) {
    final labelStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
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
            color: _accentCyan.withOpacity(0.2),
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
          _buildDescription(data),
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
            _actionButton(
              label: 'Add to Cart',
              background: _primary,
              textColor: colors.black,
              borderColor: isDark ? colors.white : colors.black,
              colors: colors,
            ),
            _actionButton(
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

  Widget _actionButton({
    required String label,
    required Color background,
    required Color textColor,
    required Color borderColor,
    required ThemeColors colors,
  }) {
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

  Widget _buildNotesSection(
    BuildContext context,
    _ResolvedNotes notes,
    bool isDark,
    ThemeColors colors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'The Notes',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
              ),
        ),
        SizedBox(height: AppTheme.spacing4.h),
        Container(
          decoration: BoxDecoration(
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isStacked = constraints.maxWidth < 900;
              return isStacked
                  ? Column(
                      children: [
                        _noteColumn(
                          title: 'Top Notes',
                          items: notes.top,
                          background: _primary,
                          borderSide: BorderSide(
                            color: isDark ? colors.white : colors.black,
                            width: AppTheme.borderWidth,
                          ),
                        ),
                        _noteColumn(
                          title: 'Heart Notes',
                          items: notes.middle,
                          background: _accentCyan,
                          borderSide: BorderSide(
                            color: isDark ? colors.white : colors.black,
                            width: AppTheme.borderWidth,
                          ),
                        ),
                        _noteColumn(
                          title: 'Base Notes',
                          items: notes.base,
                          background: isDark ? colors.zinc900 : colors.white,
                          borderSide: BorderSide(
                            color: isDark ? colors.white : colors.black,
                            width: AppTheme.borderWidth,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: _noteColumn(
                            title: 'Top Notes',
                            items: notes.top,
                            background: _primary,
                            borderSide: BorderSide(
                              color: isDark ? colors.white : colors.black,
                              width: AppTheme.borderWidth,
                            ),
                          ),
                        ),
                        Expanded(
                          child: _noteColumn(
                            title: 'Heart Notes',
                            items: notes.middle,
                            background: _accentCyan,
                            borderSide: BorderSide(
                              color: isDark ? colors.white : colors.black,
                              width: AppTheme.borderWidth,
                            ),
                          ),
                        ),
                        Expanded(
                          child: _noteColumn(
                            title: 'Base Notes',
                            items: notes.base,
                            background: isDark ? colors.zinc900 : colors.white,
                            borderSide: BorderSide(
                              color: isDark ? colors.white : colors.black,
                              width: AppTheme.borderWidth,
                            ),
                          ),
                        ),
                      ],
                    );
            },
          ),
        ),
      ],
    );
  }

  Widget _noteColumn({
    required String title,
    required List<String> items,
    required Color background,
    required BorderSide borderSide,
  }) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing6.w),
      decoration: BoxDecoration(
        color: background,
        border: Border(
          right: BorderSide.none,
          bottom: borderSide,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              decoration: TextDecoration.underline,
              decorationThickness: 4,
            ),
          ),
          SizedBox(height: AppTheme.spacing4.h),
          ...items.map(
            (note) => Padding(
              padding: EdgeInsets.only(bottom: AppTheme.spacing2.h),
              child: Text(
                '— $note',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(
    BuildContext context,
    FragellaFragrance data,
    bool isDark,
    ThemeColors colors,
  ) {
    final rating = data.rating.isNotEmpty ? data.rating : '4.9';
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
                return _reviewCard(context, isDark, colors, index);
              },
            );
          },
        ),
        SizedBox(height: AppTheme.spacing4.h),
        Center(
          child: _actionButton(
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

  Widget _reviewCard(
    BuildContext context,
    bool isDark,
    ThemeColors colors,
    int index,
  ) {
    final backgrounds = [colors.white, colors.white, _primary];
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

  Widget _buildCtaSection(
    BuildContext context,
    bool isDark,
    ThemeColors colors,
  ) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing6.w),
      decoration: BoxDecoration(
        color: _accentCyan,
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
          _actionButton(
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

  Widget _buildFooter(
    BuildContext context,
    bool isDark,
    ThemeColors colors,
  ) {
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
                    Expanded(child: _footerBrand(context, isDark, colors)),
                    Expanded(child: _footerInfo(context, isDark, colors)),
                    Expanded(child: _footerSocial(context, isDark, colors)),
                    Expanded(child: _footerSubscribe(context, isDark, colors)),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _footerBrand(context, isDark, colors),
                  SizedBox(height: AppTheme.spacing4.h),
                  _footerInfo(context, isDark, colors),
                  SizedBox(height: AppTheme.spacing4.h),
                  _footerSocial(context, isDark, colors),
                  SizedBox(height: AppTheme.spacing4.h),
                  _footerSubscribe(context, isDark, colors),
                ],
              );
            },
          ),
          SizedBox(height: AppTheme.spacing6.h),
          Center(
            child: Text(
              '© 2024 AURA SCENTS LABORATORY. ALL RIGHTS RESERVED.',
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

  Widget _footerBrand(BuildContext context, bool isDark, ThemeColors colors) {
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

  Widget _footerInfo(BuildContext context, bool isDark, ThemeColors colors) {
    return _footerLinks(
      context,
      title: 'Info',
      links: const ['Shipping', 'Returns', 'Stockists'],
      isDark: isDark,
      colors: colors,
    );
  }

  Widget _footerSocial(BuildContext context, bool isDark, ThemeColors colors) {
    return _footerLinks(
      context,
      title: 'Social',
      links: const ['Instagram', 'TikTok', 'Vimeo'],
      isDark: isDark,
      colors: colors,
    );
  }

  Widget _footerSubscribe(
    BuildContext context,
    bool isDark,
    ThemeColors colors,
  ) {
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
    required bool isDark,
    required ThemeColors colors,
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

  List<String> _splitName(String name) {
    final parts = name.trim().split(' ');
    if (parts.length <= 1) {
      return [name];
    }
    if (parts.length == 2) {
      return parts;
    }
    return [parts.first, parts.sublist(1).join(' ')];
  }

  String _buildDescription(FragellaFragrance data) {
    final accords = data.mainAccords.take(3).join(', ');
    final country = data.country.isNotEmpty ? data.country : 'Global';
    final year = data.year.isNotEmpty ? data.year : 'Unknown year';
    return 'A sensory exploration of $accords. Crafted in $country, launched in $year.';
  }

  _ResolvedNotes _resolveNotes(FragellaFragrance data) {
    if (data.notes.top.isNotEmpty ||
        data.notes.middle.isNotEmpty ||
        data.notes.base.isNotEmpty) {
      return _ResolvedNotes(
        top: _noteNames(data.notes.top),
        middle: _noteNames(data.notes.middle),
        base: _noteNames(data.notes.base),
      );
    }

    final general = data.generalNotes.isNotEmpty
        ? data.generalNotes
        : const ['Bergamot', 'Amber', 'Cedar'];
    final third = (general.length / 3).ceil();
    return _ResolvedNotes(
      top: general.take(third).toList(),
      middle: general.skip(third).take(third).toList(),
      base: general.skip(third * 2).toList(),
    );
  }

  List<String> _noteNames(List<FragellaNote> notes) {
    return notes.map((note) => note.name).where((name) => name.isNotEmpty).toList();
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

class _DetailsHeader extends SliverPersistentHeaderDelegate {
  _DetailsHeader({required this.isDark, required this.colors});

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
  bool shouldRebuild(covariant _DetailsHeader oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}

class _ResolvedNotes {
  const _ResolvedNotes({
    required this.top,
    required this.middle,
    required this.base,
  });

  final List<String> top;
  final List<String> middle;
  final List<String> base;
}