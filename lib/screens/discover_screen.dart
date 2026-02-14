import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/discover_provider.dart';
import '../providers/responsive_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/discover/discover_widgets.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final TextEditingController _searchController =
      TextEditingController(text: 'Dior');

  static const List<Map<String, String>> _filters = [
    {'label': 'Woody', 'color': 'lime'},
    {'label': 'Floral', 'color': 'white'},
    {'label': 'Citrus', 'color': 'orange'},
    {'label': 'Oud', 'color': 'white'},
    {'label': 'Spicy', 'color': 'pink'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DiscoverProvider>().ensureInitialLoad(
            query: _searchController.text,
          );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final colors = context.watch<ThemeProvider>().colors;
    final responsive = context.watch<ResponsiveProvider>();
    final isSmall = responsive.isSmall;
    final isMedium = responsive.isMedium;
    final gridColumns = isSmall ? 1 : (isMedium ? 2 : 3);
    final discover = context.watch<DiscoverProvider>();
    final results = discover.results;

    return Scaffold(
      backgroundColor: isDark ? DiscoverStyle.bgDark : DiscoverStyle.bgLight,
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: DiscoverNavBar(
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
                color: DiscoverStyle.primary.withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(
                    color: colors.black,
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
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: colors.black,
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
            delegate: DiscoverFilterBar(
              height: isSmall ? 72.h : 64.h,
              isSmall: isSmall,
              isDark: isDark,
              filters: _filters,
              onSearch: _onSearch,
              searchController: _searchController,
            ),
          ),
          if (discover.isLoading)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: AppTheme.spacing8.h),
                child: const Center(child: CircularProgressIndicator()),
              ),
            )
          else if (discover.errorMessage.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: AppTheme.spacing8.h),
                child: Center(
                  child: Text(
                    discover.errorMessage,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ),
            )
          else if (results.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: AppTheme.spacing8.h),
                child: Center(
                  child: Text(
                    'No fragrances found.',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ),
            )
          else
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
                    final fragrance = results[index];
                    return DiscoverCard(fragrance: fragrance);
                  },
                  childCount: results.length,
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: DiscoverFooter(isSmall: isSmall),
          ),
        ],
      ),
    );
  }

  void _onSearch(String query) {
    if (query.trim().length < 3) {
      return;
    }
    context.read<DiscoverProvider>().search(query: query.trim());
  }
}