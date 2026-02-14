import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart';
import '../models/marketplace_product.dart';
import '../providers/marketplace_catalog_provider.dart';
import '../providers/marketplace_filter_provider.dart';
import '../providers/responsive_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/layout_widgets.dart';
import '../widgets/neo_widgets.dart';

class MarketplaceScreen extends StatelessWidget {
  MarketplaceScreen({super.key, this.header, this.footer});

  final Widget? header;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MarketplaceFilterProvider()),
        Provider(create: (_) => MarketplaceCatalogProvider()),
      ],
      child: Builder(
        builder: (context) {
          final brightness = Theme.of(context).brightness;
          final bgColor = brightness == Brightness.light
              ? AppTheme.backgroundLight
              : AppTheme.backgroundDark;
          final responsive = context.watch<ResponsiveProvider>();
          final isSmall = responsive.isSmall;
          final isMedium = responsive.isMedium;
          final isLarge = responsive.isLarge;
          final filters = context.watch<MarketplaceFilterProvider>();
          final catalog = context.watch<MarketplaceCatalogProvider>();
          final products = filters.applyFilters(catalog.products);
          final sidebarWidth = isLarge ? 320.w : 260.w;

          final headerWidget = header ?? const AppHeader();
          final footerWidget = footer ?? const AppFooter();

          return Scaffold(
            backgroundColor: bgColor,
            body: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      headerWidget,
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppTheme.spacing4.w,
                          vertical: AppTheme.spacing6.h,
                        ),
                        child: isSmall
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildMobileFiltersPanel(context, filters),
                                  SizedBox(height: AppTheme.spacing6.h),
                                  _buildProductsSection(
                                    context,
                                    isSmall,
                                    filters,
                                    products,
                                  ),
                                ],
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Sidebar (Desktop/Tablet)
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: sidebarWidth,
                                    ),
                                    child: _buildFiltersSidebar(
                                      context,
                                      filters,
                                      showTitle: true,
                                    ),
                                  ),
                                  SizedBox(width: AppTheme.spacing6.w),
                                  // Products Grid
                                  Expanded(
                                    child: _buildProductsSection(
                                      context,
                                      isSmall,
                                      filters,
                                      products,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      footerWidget,
                    ],
                  ),
                ),
                if (kDebugMode)
                  Positioned(
                    right: AppTheme.spacing4.w,
                    bottom: AppTheme.spacing4.h,
                    child: _buildDebugSizeBadge(
                      context,
                      isSmall: isSmall,
                      isMedium: isMedium,
                      isLarge: isLarge,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDebugSizeBadge(
    BuildContext context, {
    required bool isSmall,
    required bool isMedium,
    required bool isLarge,
  }) {
    final size = MediaQuery.sizeOf(context);
    final label = isSmall ? 'SM' : (isMedium ? 'MD' : 'LG');

    return NeoCard(
      backgroundColor: AppTheme.white,
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacing4.w,
        vertical: AppTheme.spacing2.h,
      ),
      child: Text(
        '${size.width.toStringAsFixed(0)}x${size.height.toStringAsFixed(0)} $label',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.black,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }

  Widget _buildFiltersSidebar(
    BuildContext context,
    MarketplaceFilterProvider filters,
    {required bool showTitle}
  ) {
    final brightness = Theme.of(context).brightness;
    final textColor =
        brightness == Brightness.light ? AppTheme.black : AppTheme.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppTheme.spacing6,
      children: [
        if (showTitle)
          Text(
            'Filters',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                ),
          ),
        // Category
        _buildFilterSection(
          context,
          'CATEGORY',
          MarketplaceFilterProvider.categories,
          filters.selectedCategory,
          (value) => filters.setSelectedCategory(value),
        ),
        // Intensity
        _buildIntensityGrid(context, filters),
        // Price Range
        _buildPriceRange(context, filters),
      ],
    );
  }

  Widget _buildMobileFiltersPanel(
    BuildContext context,
    MarketplaceFilterProvider filters,
  ) {
    final brightness = Theme.of(context).brightness;
    final textColor =
        brightness == Brightness.light ? AppTheme.black : AppTheme.white;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: NeoCard(
        padding: EdgeInsets.zero,
        child: ExpansionTile(
          title: Text(
            'Filters',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                ),
          ),
          childrenPadding: EdgeInsets.symmetric(
            horizontal: AppTheme.spacing4.w,
            vertical: AppTheme.spacing4.h,
          ),
          children: [
            _buildFiltersSidebar(context, filters, showTitle: false),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(
    BuildContext context,
    String title,
    List<String> options,
    String selected,
    ValueChanged<String> onChanged,
  ) {
    final brightness = Theme.of(context).brightness;
    final textColor =
        brightness == Brightness.light ? AppTheme.black : AppTheme.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppTheme.spacing2,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        ...options.map((option) {
          final isSelected = option == selected;
          return GestureDetector(
            onTap: () => onChanged(option),
            child: NeoCard(
              backgroundColor: isSelected ? AppTheme.primaryYellow : null,
              shadow: isSelected,
              shadowOffset: AppTheme.shadowSmall,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing4,
                vertical: AppTheme.spacing2,
              ),
              child: Text(
                option.toUpperCase(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isSelected ? AppTheme.black : textColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildIntensityGrid(
    BuildContext context,
    MarketplaceFilterProvider filters,
  ) {
    final brightness = Theme.of(context).brightness;
    final borderColor =
        brightness == Brightness.light ? AppTheme.black : AppTheme.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppTheme.spacing2,
      children: [
        Text(
          'INTENSITY',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppTheme.spacing2,
            crossAxisSpacing: AppTheme.spacing2,
            // Approximate Tailwind py-2 button height
            mainAxisExtent: 36,
          ),
          itemCount: MarketplaceFilterProvider.intensities.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final intensity = MarketplaceFilterProvider.intensities[index];
            final isSelected = intensity == filters.selectedIntensity;
            return GestureDetector(
              onTap: () => filters.setSelectedIntensity(intensity),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 160.w),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing2,
                      vertical: AppTheme.spacing2 * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.black : Colors.transparent,
                      border: Border.all(
                        color: borderColor,
                        width: AppTheme.borderWidth,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        intensity.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color:
                                  isSelected ? AppTheme.white : borderColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPriceRange(
    BuildContext context,
    MarketplaceFilterProvider filters,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppTheme.spacing2,
      children: [
        Text(
          'PRICE RANGE',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        Slider(
          value: filters.priceRange,
          min: 0,
          max: 500,
          onChanged: (value) => filters.setPriceRange(value),
          activeColor: AppTheme.primaryYellow,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '\$0',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            Text(
              '\$500+',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProductsSection(
    BuildContext context,
    bool isSmall,
    MarketplaceFilterProvider filters,
    List<MarketplaceProduct> products,
  ) {
    final brightness = Theme.of(context).brightness;
    final textColor =
        brightness == Brightness.light ? AppTheme.black : AppTheme.white;
    final responsive = context.watch<ResponsiveProvider>();
    final isLarge = responsive.isLarge;
    final isMedium = responsive.isMedium;

    final accentColor =
        brightness == Brightness.light ? AppTheme.accentPink : AppTheme.accentCyan;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppTheme.spacing6,
      children: [
        // Header
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppTheme.spacing2,
          children: [
            Text(
              'Curated Collection'.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3,
                    fontSize: 12,
                  ),
            ),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w900,
                      fontSize: isLarge ? 96 : 60,
                      height: 0.95,
                      letterSpacing: -1,
                    ),
                children: [
                  const TextSpan(text: 'Catalog'),
                  TextSpan(
                    text: '.24',
                    style: TextStyle(color: accentColor),
                  ),
                ],
              ),
            ),
          ],
        ),
        // Sort
        NeoCard(
          padding: const EdgeInsets.all(AppTheme.spacing4),
          child: Row(
            children: [
              Text(
                'Sort by:'.toUpperCase(),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
              ),
              SizedBox(width: AppTheme.spacing4),
              Expanded(
                child: DropdownButton<String>(
                  value: filters.sortBy,
                  isExpanded: true,
                  underline: SizedBox(),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                        color: textColor,
                      ),
                  items: MarketplaceFilterProvider.sortOptions
                      .map((option) => DropdownMenuItem(
                            value: option,
                            child: Text(option.toUpperCase()),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      filters.setSortBy(value);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        // Products Grid
        GridView.count(
          crossAxisCount: isSmall ? 1 : (isMedium ? 2 : 3),
          childAspectRatio: isSmall ? 0.9 : (isMedium ? 0.8 : 0.75),
          mainAxisSpacing: AppTheme.spacing6,
          crossAxisSpacing: AppTheme.spacing6,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: products
              .map((product) => _MarketplaceProductCard(product: product))
              .toList(),
        ),
        // Load More Button
        Center(
          child: NeoButton(
            label: 'Load More Entries +',
            onPressed: () {},
            italic: true,
            height: 64,
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacing8,
            ),
            textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
            // Use default height to stay consistent with other buttons
            // and avoid oversized CTAs on this page.
          ),
        ),
        Center(
          child: NeoButton(
            label: 'Add Your Perfume',
            onPressed: () {},
            backgroundColor: AppTheme.white,
            textColor: AppTheme.black,
            italic: true,
            height: 56,
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacing8,
            ),
            textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
        ),
        SizedBox(height: AppTheme.spacing6),
      ],
    );
  }
}

class _MarketplaceProductCard extends StatelessWidget {
  final MarketplaceProduct product;

  const _MarketplaceProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final defaultTextColor =
        brightness == Brightness.light ? AppTheme.black : AppTheme.white;

    final Color bgColor = product.bgColor;
    final String imageUrl = product.imageUrl;
    final bool isBestSeller = product.isBestSeller;

    // Ensure good contrast on very dark backgrounds
    final Color textColor =
        (bgColor == AppTheme.black && brightness == Brightness.light)
            ? AppTheme.white
            : defaultTextColor;

    return NeoCard(
      backgroundColor: bgColor,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 220,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: AppTheme.spacing2,
                  right: AppTheme.spacing2,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing4,
                      vertical: AppTheme.spacing2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      border: Border.all(
                        color: defaultTextColor,
                        width: AppTheme.borderWidth,
                      ),
                    ),
                    child: Text(
                        product.priceLabel,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppTheme.black,
                          ),
                    ),
                  ),
                ),
                if (isBestSeller)
                  Positioned(
                    bottom: AppTheme.spacing2,
                    left: AppTheme.spacing2,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing2,
                        vertical: AppTheme.spacing2 / 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryYellow,
                        border: Border.all(
                          color: defaultTextColor,
                          width: AppTheme.borderWidth,
                        ),
                      ),
                      child: Text(
                        'Best Seller'.toUpperCase(),
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.black,
                            ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacing4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppTheme.spacing2,
              children: [
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                      ),
                ),
                Text(
                  product.category,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: textColor.withValues(
                          alpha: 0.7,
                        ),
                        fontWeight: FontWeight.w700,
                      ),
                ),
                SizedBox(height: AppTheme.spacing2),
                NeoButton(
                  label: 'Add to Vault',
                  onPressed: () {},
                  backgroundColor: AppTheme.black,
                  textColor: AppTheme.white,
                  height: 48,
                  isFullWidth: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
