import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/layout_widgets.dart';
import '../widgets/neo_widgets.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  String _selectedCategory = 'All Scents';
  String _selectedIntensity = 'Subtle';
  double _priceRange = 250;
  String _sortBy = 'Newest First';

  final List<String> _categories = [
    'All Scents',
    'Floral',
    'Woody',
    'Oriental',
    'Fresh',
  ];

  final List<String> _intensities = [
    'Subtle',
    'Strong',
    'Vibrant',
    'Heavy',
  ];

  final List<String> _sortOptions = [
    'Newest First',
    'Price: Low-High',
    'Most Intense',
  ];

  final List<Map<String, dynamic>> _products = [
    {
      'name': 'Electric Petal',
      'category': 'Floral / Ozone / Neon',
      'price': '\$120',
      'bgColor': AppTheme.accentCyan,
      'isBestSeller': false,
    },
    {
      'name': 'Nuclear Amber',
      'category': 'Resin / Smoke / Static',
      'price': '\$185',
      'bgColor': AppTheme.accentPink,
      'isBestSeller': true,
    },
    {
      'name': 'Void Water',
      'category': 'Mineral / Cold / Salt',
      'price': '\$95',
      'bgColor': AppTheme.primaryYellow,
      'isBestSeller': false,
    },
    {
      'name': 'Glitch Moss',
      'category': 'Damp Earth / Chrome / Ink',
      'price': '\$145',
      'bgColor': AppTheme.accentGreen,
      'isBestSeller': false,
    },
    {
      'name': 'Abstract Paper',
      'category': 'White Musk / Wood / Fiber',
      'price': '\$210',
      'bgColor': AppTheme.white,
      'isBestSeller': false,
    },
    {
      'name': 'Black Hole',
      'category': 'Darkness / Velvet / Gravity',
      'price': '\$300',
      'bgColor': AppTheme.black,
      'isBestSeller': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bgColor = brightness == Brightness.light
        ? AppTheme.backgroundLight
        : AppTheme.backgroundDark;
    final isSmall = MediaQuery.of(context).size.width < 640;

    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AppHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing4,
                vertical: AppTheme.spacing6,
              ),
              child: Row(
                children: [
                  // Sidebar (Desktop Only)
                  if (!isSmall)
                    Expanded(
                      flex: 2,
                      child: _buildFiltersSidebar(context),
                    ),
                  if (!isSmall) SizedBox(width: AppTheme.spacing6),
                  // Products Grid
                  Expanded(
                    flex: 3,
                    child: _buildProductsSection(context, isSmall),
                  ),
                ],
              ),
            ),
            const AppFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersSidebar(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final textColor =
        brightness == Brightness.light ? AppTheme.black : AppTheme.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppTheme.spacing6,
      children: [
        Text(
          'FILTERS',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w800,
              ),
        ),
        // Category
        _buildFilterSection(
          context,
          'CATEGORY',
          _categories,
          _selectedCategory,
          (value) => setState(() => _selectedCategory = value),
        ),
        // Intensity
        _buildIntensityGrid(context),
        // Price Range
        _buildPriceRange(context),
      ],
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
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing4,
                vertical: AppTheme.spacing2,
              ),
              child: Text(
                option,
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

  Widget _buildIntensityGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppTheme.spacing2,
      children: [
        Text(
          'INTENSITY',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: AppTheme.spacing2,
          crossAxisSpacing: AppTheme.spacing2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: _intensities.map((intensity) {
            final isSelected = intensity == _selectedIntensity;
            return GestureDetector(
              onTap: () => setState(() => _selectedIntensity = intensity),
              child: NeoCard(
                backgroundColor: isSelected ? AppTheme.black : null,
                padding: const EdgeInsets.all(AppTheme.spacing2),
                child: Center(
                  child: Text(
                    intensity,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isSelected ? AppTheme.white : null,
                          fontSize: 10,
                        ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceRange(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppTheme.spacing2,
      children: [
        Text(
          'PRICE RANGE',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        Slider(
          value: _priceRange,
          min: 0,
          max: 500,
          onChanged: (value) => setState(() => _priceRange = value),
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
              '\$${_priceRange.toInt()}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProductsSection(BuildContext context, bool isSmall) {
    final brightness = Theme.of(context).brightness;
    final textColor =
        brightness == Brightness.light ? AppTheme.black : AppTheme.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppTheme.spacing6,
      children: [
        // Header
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppTheme.spacing2,
          children: [
            NeoBadge(
              label: 'Curated Collection',
              backgroundColor: AppTheme.accentPink,
              textColor: AppTheme.white,
            ),
            Text(
              'Catalog.24',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w800,
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
                'Sort by:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              SizedBox(width: AppTheme.spacing4),
              Expanded(
                child: DropdownButton<String>(
                  value: _sortBy,
                  isExpanded: true,
                  underline: SizedBox(),
                  items: _sortOptions
                      .map((option) => DropdownMenuItem(
                            value: option,
                            child: Text(option),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _sortBy = value);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        // Products Grid
        GridView.count(
          crossAxisCount: isSmall ? 1 : 3,
          mainAxisSpacing: AppTheme.spacing6,
          crossAxisSpacing: AppTheme.spacing6,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: _products.map((product) {
            return _buildProductCard(context, product);
          }).toList(),
        ),
        // Load More Button
        Center(
          child: NeoButton(
            label: 'Load More Entries +',
            onPressed: () {},
            italic: true,
            // Use default height to stay consistent with other buttons
            // and avoid oversized CTAs on this page.
          ),
        ),
        SizedBox(height: AppTheme.spacing6),
      ],
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product) {
    final brightness = Theme.of(context).brightness;
    final textColor =
        brightness == Brightness.light ? AppTheme.black : AppTheme.white;

    return NeoCard(
      backgroundColor: product['bgColor'],
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: textColor,
                  width: AppTheme.borderWidth,
                ),
              ),
            ),
            child: Center(
              child: Text(
                '[Image]',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          // Product info
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacing4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppTheme.spacing2,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product['name'],
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    Text(
                      product['price'],
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ],
                ),
                if (product['isBestSeller'])
                  NeoBadge(
                    label: 'Best Seller',
                    backgroundColor: AppTheme.primaryYellow,
                    textColor: AppTheme.black,
                  ),
                Text(
                  product['category'],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: textColor,
                      ),
                  maxLines: 2,
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
