import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/fragella_fragrance.dart';
import '../models/marketplace_product.dart';
import '../providers/marketplace_api_provider.dart';
import '../providers/marketplace_filter_provider.dart';
import '../providers/responsive_provider.dart';
import '../services/fragella_api_client.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/layout_widgets.dart';
import '../widgets/neo_widgets.dart';

class MarketplaceScreen extends StatefulWidget {
  MarketplaceScreen({super.key, this.header, this.footer});

  final Widget? header;
  final Widget? footer;

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final TextEditingController _searchController =
      TextEditingController(text: 'fragrance');
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final apiClient = context.read<FragellaApiClient>();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MarketplaceFilterProvider()),
        ChangeNotifierProvider(
          create: (_) => MarketplaceApiProvider(apiClient: apiClient),
        ),
      ],
      child: Builder(
        builder: (context) {
          final brightness = Theme.of(context).brightness;
          final colors = context.watch<ThemeProvider>().colors;
          final bgColor = brightness == Brightness.light
              ? colors.backgroundLight
              : colors.backgroundDark;
          final responsive = context.watch<ResponsiveProvider>();
          final isSmall = responsive.isSmall;
          final isLarge = responsive.isLarge;
          final filters = context.watch<MarketplaceFilterProvider>();
          final apiProvider = context.watch<MarketplaceApiProvider>();
          context.read<MarketplaceApiProvider>().ensureLoaded();
          final mappedProducts = _mapToMarketplaceProducts(
            apiProvider.items,
            colors,
          );
          final products = filters.applyFilters(mappedProducts);
          final sidebarWidth = isLarge ? 320.w : 260.w;

          final headerWidget = widget.header ?? const AppHeader();
          final footerWidget = widget.footer ?? const AppFooter();

          return Scaffold(
            backgroundColor: bgColor,
            body: SingleChildScrollView(
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
                                apiProvider: apiProvider,
                                isLoading: apiProvider.isLoading,
                                errorMessage: apiProvider.errorMessage,
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
                                  apiProvider: apiProvider,
                                  isLoading: apiProvider.isLoading,
                                  errorMessage: apiProvider.errorMessage,
                                ),
                              ),
                            ],
                          ),
                  ),
                  footerWidget,
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFiltersSidebar(
    BuildContext context,
    MarketplaceFilterProvider filters,
    {required bool showTitle}
  ) {
    final brightness = Theme.of(context).brightness;
    final colors = context.watch<ThemeProvider>().colors;
    final textColor =
        brightness == Brightness.light ? colors.black : colors.white;

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
    final colors = context.watch<ThemeProvider>().colors;
    final textColor =
        brightness == Brightness.light ? colors.black : colors.white;

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
    final colors = context.watch<ThemeProvider>().colors;
    final textColor =
        brightness == Brightness.light ? colors.black : colors.white;

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
              backgroundColor: isSelected ? colors.primaryYellow : null,
              shadow: isSelected,
              shadowOffset: AppTheme.shadowSmall,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing4,
                vertical: AppTheme.spacing2,
              ),
              child: Text(
                option.toUpperCase(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isSelected ? colors.black : textColor,
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
    final colors = context.watch<ThemeProvider>().colors;
    final borderColor =
        brightness == Brightness.light ? colors.black : colors.white;

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
                      color: isSelected ? colors.black : Colors.transparent,
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
                                  isSelected ? colors.white : borderColor,
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
    final colors = context.watch<ThemeProvider>().colors;
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
          activeColor: colors.primaryYellow,
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
    {
    required MarketplaceApiProvider apiProvider,
    required bool isLoading,
    required String errorMessage,
  }
  ) {
    final brightness = Theme.of(context).brightness;
    final colors = context.watch<ThemeProvider>().colors;
    final textColor =
        brightness == Brightness.light ? colors.black : colors.white;
    final responsive = context.watch<ResponsiveProvider>();
    final isLarge = responsive.isLarge;
    final isMedium = responsive.isMedium;
    final desiredColumns = isSmall ? 1 : (isMedium ? 2 : 3);

    final accentColor =
      brightness == Brightness.light
        ? colors.accentPink
        : colors.accentCyan;

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
        NeoCard(
          padding: const EdgeInsets.all(AppTheme.spacing4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  onSubmitted: _onSearch,
                  decoration: const InputDecoration(
                    hintText: 'Search perfume (e.g. Dior)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              SizedBox(width: AppTheme.spacing4.w),
              NeoButton(
                label: 'Search',
                onPressed: () => _onSearch(_searchController.text),
                height: 48,
              ),
            ],
          ),
        ),
        Text(
          'Results for: ${apiProvider.lastQuery}',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
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
        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppTheme.spacing6),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing6),
            child: Center(
              child: Text(
                errorMessage,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          )
        else if (products.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing6),
            child: Center(
              child: Text(
                'No perfumes found.',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = _resolveGridColumns(
                constraints.maxWidth,
                desiredColumns,
              );
              final tileHeight = isSmall
                  ? 420.h
                  : (isMedium ? 440.h : 460.h);

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: AppTheme.spacing6,
                  crossAxisSpacing: AppTheme.spacing6,
                  mainAxisExtent: tileHeight,
                ),
                itemCount: products.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return _MarketplaceProductCard(product: products[index]);
                },
              );
            },
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
            backgroundColor: colors.white,
            textColor: colors.black,
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

  int _resolveGridColumns(double maxWidth, int desiredColumns) {
    const minTileWidth = 300.0;
    var columns = desiredColumns;

    while (columns > 1 && (maxWidth / columns) < minTileWidth) {
      columns -= 1;
    }

    return columns;
  }

  List<MarketplaceProduct> _mapToMarketplaceProducts(
    List<FragellaFragrance> fragrances,
    ThemeColors colors,
  ) {
    return fragrances.map((fragrance) {
      final accords = fragrance.mainAccords.map((e) => e.toLowerCase()).toList();

      return MarketplaceProduct(
        name: fragrance.name,
        category: accords.isNotEmpty
            ? accords.take(3).map(_capitalize).join(' / ')
            : 'Uncategorized',
        priceLabel: fragrance.price.isNotEmpty ? '\$${fragrance.price}' : '—',
        priceValue: _parsePrice(fragrance.price),
        bgColor: _backgroundForAccords(accords, colors),
        isBestSeller: fragrance.popularity.toLowerCase().contains('very high') ||
            fragrance.confidence.toLowerCase() == 'high',
        imageUrl: fragrance.imageUrl,
        fragrance: fragrance,
      );
    }).toList();
  }

  Color _backgroundForAccords(List<String> accords, ThemeColors colors) {
    if (accords.any((a) => a.contains('floral'))) {
      return colors.accentPink;
    }
    if (accords.any((a) => a.contains('citrus')) ||
        accords.any((a) => a.contains('fresh'))) {
      return colors.accentCyan;
    }
    if (accords.any((a) => a.contains('woody')) ||
        accords.any((a) => a.contains('green'))) {
      return colors.accentGreen;
    }
    if (accords.any((a) => a.contains('amber')) ||
        accords.any((a) => a.contains('spice'))) {
      return colors.primaryYellow;
    }
    return colors.white;
  }

  double _parsePrice(String value) {
    if (value.isEmpty) {
      return 0;
    }
    final cleaned = value.replaceAll(RegExp(r'[^0-9\.]'), '');
    return double.tryParse(cleaned) ?? 0;
  }

  String _capitalize(String text) {
    if (text.isEmpty) {
      return text;
    }
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }

  void _onSearch(String query) {
    final trimmed = query.trim();
    if (trimmed.length < 3) {
      return;
    }
    context.read<MarketplaceApiProvider>().fetchCatalog(query: trimmed);
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) {
        return;
      }
      _onSearch(value);
    });
  }
}

class _MarketplaceProductCard extends StatelessWidget {
  final MarketplaceProduct product;

  const _MarketplaceProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final colors = context.watch<ThemeProvider>().colors;
    final defaultTextColor =
      brightness == Brightness.light ? colors.black : colors.white;
    final isSmall = context.select<ResponsiveProvider, bool>(
      (provider) => provider.isSmall,
    );

    final Color bgColor = product.bgColor;
    final String imageUrl = product.imageUrl;
    final bool isBestSeller = product.isBestSeller;

    // Ensure good contrast on very dark backgrounds
    final Color textColor =
      (bgColor == colors.black && brightness == Brightness.light)
        ? colors.white
        : defaultTextColor;

    return NeoCard(
      backgroundColor: bgColor,
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              Expanded(
                flex: 6,
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
                          color: colors.white,
                          border: Border.all(
                            color: defaultTextColor,
                            width: AppTheme.borderWidth,
                          ),
                        ),
                        child: Text(
                          product.priceLabel,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: colors.black,
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
                            color: colors.primaryYellow,
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
                                  color: colors.black,
                                ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                flex: 5,
                child: Padding(
                  padding: EdgeInsets.all(
                    AppTheme.spacing4.w,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.w900,
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                          SizedBox(height: AppTheme.spacing2.h),
                          Text(
                            product.category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: textColor.withOpacity(0.7),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                      NeoButton(
                        label: 'Add to Vault',
                        onPressed: () {
                          if (product.fragrance != null) {
                            Navigator.of(context).pushNamed(
                              '/individualDetails',
                              arguments: product.fragrance,
                            );
                          }
                        },
                        backgroundColor: colors.black,
                        textColor: colors.white,
                        height: isSmall ? 44.h : 48.h,
                        isFullWidth: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
