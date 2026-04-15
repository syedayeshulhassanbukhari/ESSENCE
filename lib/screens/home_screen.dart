import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/layout_widgets.dart';
import '../widgets/neo_widgets.dart';
import '../widgets/marquee_text.dart';
import '../models/fragella_fragrance.dart';
import '../providers/home_featured_provider.dart';
import '../providers/responsive_provider.dart';
import '../providers/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<HomeFeaturedProvider>().ensureLoaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final colors = context.watch<ThemeProvider>().colors;
    final bgColor = brightness == Brightness.light
        ? colors.backgroundLight
        : colors.backgroundDark;

    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AppHeader(),
            _buildHeroSection(context),
            _buildFeaturedSection(context),
            _buildMarqueeSection(context),
            _buildCommunitySection(context),
            _buildNewsletterSection(context),
            const AppFooter(),
          ],
        ),
      ),
    );
  }
}

Widget _buildHeroSection(BuildContext context) {
  final brightness = Theme.of(context).brightness;
  final colors = context.watch<ThemeProvider>().colors;
  final textColor =
    brightness == Brightness.light ? colors.black : colors.white;
  final joinBackground =
    brightness == Brightness.light ? colors.white : colors.zinc800;
  final responsive = context.watch<ResponsiveProvider>();
  final isSmall = responsive.isSmall;
  final isWide = responsive.isLarge;

  // Match HTML: text-6xl md:text-9xl, font-display (Syne), uppercase, tight leading
  final bool isMdUp = responsive.isMedium || responsive.isLarge;
  final double heroFontSize = isMdUp ? 96.sp : 60.sp;
  final TextStyle heroHeadingStyle = GoogleFonts.syne(
    fontSize: heroFontSize,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.5,
    height: 0.85,
    color: textColor,
  );

  // Match HTML body: text-xl md:text-2xl
  final double bodyFontSize = isMdUp ? 24.sp : 20.sp;

  Widget buildTextColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const NeoBadge(label: 'Experimental Perfumery'),
        const SizedBox(height: AppTheme.spacing4),
        Text(
          'FRAGRANCE',
          style: heroHeadingStyle,
        ),
        const SizedBox(height: 8),
        Container(
          color: colors.primaryYellow,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'REDEFINED.',
            style: heroHeadingStyle.copyWith(color: colors.black),
          ),
        ),
        const SizedBox(height: AppTheme.spacing6),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing4,
            vertical: AppTheme.spacing2,
          ),
          decoration: BoxDecoration(
            color: brightness == Brightness.light
                ? colors.backgroundLight
                : colors.backgroundDark,
            border: Border(
              left: BorderSide(
                color: brightness == Brightness.light
                    ? colors.black
                    : colors.primaryYellow,
                width: AppTheme.borderWidth,
              ),
            ),
          ),
          child: Text(
            "The world's first decentralized marketplace for avant-garde perfumery. Discover scents that challenge the status quo.",
            style: GoogleFonts.spaceGrotesk(
              fontSize: bodyFontSize,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacing6),
        Row(
          children: [
            Expanded(
              child: NeoButton(
                label: 'Shop Marketplace',
                onPressed: () {},
                backgroundColor: colors.primaryYellow,
                textColor: colors.black,
              ),
            ),
            if (!isSmall) const SizedBox(width: AppTheme.spacing4),
            if (!isSmall)
              Expanded(
                child: NeoButton(
                  label: 'Join the Club',
                  onPressed: () {},
                  backgroundColor: joinBackground,
                  textColor: brightness == Brightness.light
                      ? colors.black
                      : colors.white,
                ),
              ),
          ],
        ),
      ],
    );
  }

  return Container(
    color: brightness == Brightness.light
      ? colors.backgroundLight
      : colors.black,
    child: ResponsiveLayout(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing6),
        child: isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 7, child: buildTextColumn()),
                  const SizedBox(width: AppTheme.spacing8),
                  Expanded(
                    flex: 5,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding:
                            const EdgeInsets.only(right: AppTheme.spacing2),
                        child: _buildHeroImageCard(context),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildTextColumn(),
                  const SizedBox(height: AppTheme.spacing6),
                  _buildHeroImageCard(context),
                ],
              ),
      ),
    ),
  );
}

Widget _buildHeroImageCard(BuildContext context) {
  final brightness = Theme.of(context).brightness;
  final colors = context.watch<ThemeProvider>().colors;
  final borderColor =
    brightness == Brightness.light ? colors.black : colors.primaryYellow;

    return AspectRatio(
      aspectRatio: 3 / 4,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: AppTheme.spacing4,
            bottom: AppTheme.spacing4,
            right: 0,
            top: 0,
            child: Container(
              decoration: BoxDecoration(
                color: colors.primaryYellow,
                border: Border.all(
                  color: borderColor,
                  width: AppTheme.borderWidth,
                ),
              ),
            ),
          ),
          Positioned(
            right: AppTheme.spacing4,
            top: AppTheme.spacing4,
            left: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: colors.white,
                border: Border.all(
                  color: colors.black,
                  width: AppTheme.borderWidth,
                ),
              ),
              clipBehavior: Clip.hardEdge,
              child: Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuAiTkqgXPglCr3WEjYRotSXa6boRrK_qVjj3J2cUPl8jVgA99DRFMOdhRNlmaIbungENOOLZS-47bjYCcbe-KH483JrhYK6FcnT-t9ZyJuO2PDZqdrft56gJJe5XWqfJWqY33U41QRIjSV-E26hBN_QWUhy5LssS9F2ZnY_eMNS6xGHS9ApWaIlvV2cTorH7AUodxcdodyJjJ6zfg75sDgZ4uHKPunUqsHPMNoR68dG1jBb3-58LkuDgbq-ByjoHZO0M9ancC3oH8k',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: -AppTheme.spacing4,
            left: AppTheme.spacing6,
            child: NeoCard(
              backgroundColor: colors.black,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing4,
                vertical: AppTheme.spacing2,
              ),
              child: Text(
                'EST. 2024',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colors.white,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final colors = context.watch<ThemeProvider>().colors;
    final textColor =
        brightness == Brightness.light ? colors.black : colors.white;
    final responsive = context.watch<ResponsiveProvider>();
    final isSmall = responsive.isSmall;
    final isMedium = responsive.isMedium;
    final isLarge = responsive.isLarge;
    final featured = context.watch<HomeFeaturedProvider>();
    final items = featured.items.take(6).toList();

    return ResponsiveLayout(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NeoBadge(label: 'Curated'),
            SizedBox(height: AppTheme.spacing4),
            Text(
              'DISCOVER YOUR SCENT',
              style: GoogleFonts.syne(
                fontSize: isLarge ? 64.sp : (isMedium ? 56.sp : 48.sp),
                fontWeight: FontWeight.w800,
                letterSpacing: -1.0,
                color: textColor,
              ),
            ),
            SizedBox(height: AppTheme.spacing6),
            if (featured.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppTheme.spacing6),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (featured.errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing6),
                child: Text(
                  featured.errorMessage,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              )
            else if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing6),
                child: Text(
                  'No featured perfumes found.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              )
            else
              GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isSmall ? 1 : (isMedium ? 2 : 3),
                  childAspectRatio: isSmall ? 0.9 : 0.75,
                  mainAxisSpacing: AppTheme.spacing6,
                  crossAxisSpacing: AppTheme.spacing6,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return _buildProductCard(context, items[index]);
                },
              ),
            SizedBox(height: AppTheme.spacing6),
            Align(
              alignment: Alignment.centerRight,
              child: NeoButton(
                label: 'View All Releases',
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    FragellaFragrance fragrance,
  ) {
    final brightness = Theme.of(context).brightness;
    final colors = context.watch<ThemeProvider>().colors;
    final textColor =
        brightness == Brightness.light ? colors.black : colors.white;
    final isSoldOut = fragrance.popularity.toLowerCase().contains('out of stock');
    final badge = fragrance.year.isNotEmpty ? 'NEW' : null;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/individualDetails', arguments: fragrance);
      },
      child: NeoCard(
        backgroundColor:
            brightness == Brightness.light ? colors.white : colors.zinc900,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: textColor,
                      width: AppTheme.borderWidth,
                    ),
                  ),
                  color: const Color(0xFF999999),
                ),
                child: fragrance.imageUrl.isNotEmpty
                    ? Image.network(
                        fragrance.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Text(
                              '[Image]',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Text(
                          '[Image]',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacing4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          fragrance.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ],
                  ),
                  if (badge != null) ...[
                    const SizedBox(height: AppTheme.spacing2),
                    NeoBadge(label: badge),
                  ],
                  const SizedBox(height: AppTheme.spacing4),
                  NeoButton(
                    label: isSoldOut ? 'Waitlist' : 'View Details',
                    onPressed: () {
                      Navigator.of(context).pushNamed('/individualDetails', arguments: fragrance);
                    },
                    backgroundColor:
                        isSoldOut ? const Color(0xFFCCCCCC) : colors.black,
                    textColor: colors.white,
                    height: 48,
                    isFullWidth: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarqueeSection(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    // Match HTML marquee: font-display (Syne), text-4xl, uppercase, primary yellow
    final textStyle = GoogleFonts.syne(
      fontSize: 36,
      fontWeight: FontWeight.w800,
      letterSpacing: 0,
      color: colors.primaryYellow,
    );

    return Container(
      color: colors.black,
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing4),
      child: MarqueeText(
        text:
            'Limited Drops Only — Rare Ingredients — Artisanal Methods — Limited Drops Only — Rare Ingredients — Artisanal Methods — Limited Drops Only — Rare Ingredients — Artisanal Methods —',
        style: textStyle,
        gap: AppTheme.spacing8,
        duration: const Duration(seconds: 20),
      ),
    );
  }

  Widget _buildCommunitySection(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final isSmall = context.select<ResponsiveProvider, bool>(
      (provider) => provider.isSmall,
    );

    return ResponsiveLayout(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing6),
        child: !isSmall
            ? Row(
                children: [
                  Expanded(
                    child: NeoCard(
                      backgroundColor: colors.primaryYellow,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'The\nCommunity\nVault',
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                  color: colors.black,
                                  height: 0.9,
                                ),
                          ),
                          SizedBox(height: AppTheme.spacing4),
                          Text(
                            'Our community votes on which discontinued scents get resurrected.',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: colors.black,
                                ),
                          ),
                          SizedBox(height: AppTheme.spacing4),
                          NeoButton(
                            label: 'Enter The Vault',
                            onPressed: () {},
                            backgroundColor: colors.black,
                            textColor: colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: AppTheme.spacing6),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: AppTheme.spacing4,
                      crossAxisSpacing: AppTheme.spacing4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildFeatureCard(
                          context,
                          title: 'Molecular Lab',
                          description:
                              'Synthesis of nature and machine. Pure high-performance extractions.',
                          icon: Icons.science,
                        ),
                        _buildFeatureCard(
                          context,
                          title: 'Bio-Sourced',
                          description:
                              '100% ethical sourcing from regenerative micro-farms worldwide.',
                          icon: Icons.eco,
                        ),
                        _buildFeatureCard(
                          context,
                          title: 'Verified Authenticity',
                          description:
                              'Each bottle is serialized and authenticated via digital vault.',
                          icon: Icons.verified_user,
                        ),
                        _buildFeatureCard(
                          context,
                          title: 'Rapid Drops',
                          description:
                              'Fresh formulations released every first Monday of the month.',
                          icon: Icons.rocket_launch,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  NeoCard(
                    backgroundColor: colors.primaryYellow,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'The Community Vault',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: colors.black,
                              ),
                        ),
                        SizedBox(height: AppTheme.spacing4),
                        Text(
                          'Our community votes on which discontinued scents get resurrected. Have your say in the future of fragrance.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colors.black,
                              ),
                        ),
                        SizedBox(height: AppTheme.spacing4),
                        NeoButton(
                          label: 'Enter The Vault',
                          onPressed: () {},
                          isFullWidth: true,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppTheme.spacing6),
                  _buildFeatureCard(
                    context,
                    title: 'Molecular Lab',
                    description:
                        'Synthesis of nature and machine. Pure high-performance extractions.',
                    icon: Icons.science,
                  ),
                  SizedBox(height: AppTheme.spacing4),
                  _buildFeatureCard(
                    context,
                    title: 'Bio-Sourced',
                    description:
                        '100% ethical sourcing from regenerative micro-farms worldwide.',
                    icon: Icons.eco,
                  ),
                  SizedBox(height: AppTheme.spacing4),
                  _buildFeatureCard(
                    context,
                    title: 'Verified Authenticity',
                    description:
                        'Each bottle is serialized and authenticated via digital vault.',
                    icon: Icons.verified_user,
                  ),
                  SizedBox(height: AppTheme.spacing4),
                  _buildFeatureCard(
                    context,
                    title: 'Rapid Drops',
                    description:
                        'Fresh formulations released every first Monday of the month.',
                    icon: Icons.rocket_launch,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
  }) {
    final brightness = Theme.of(context).brightness;
    final colors = context.watch<ThemeProvider>().colors;
    final borderColor =
        brightness == Brightness.light ? colors.black : colors.primaryYellow;

    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing2),
            decoration: BoxDecoration(
              color: colors.primaryYellow,
              border: Border.all(color: borderColor, width: AppTheme.borderWidth / 2),
            ),
            child: Icon(icon, color: colors.black, size: 28),
          ),
          SizedBox(height: AppTheme.spacing4),
          Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          SizedBox(height: AppTheme.spacing2),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildNewsletterSection(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final colors = context.watch<ThemeProvider>().colors;
    final textColor =
      brightness == Brightness.light ? colors.black : colors.white;
    // Newsletter input border: black in light mode, primary yellow in dark mode like discover.html
    final borderColor =
      brightness == Brightness.light ? colors.black : colors.primaryYellow;
    final isSmall = context.select<ResponsiveProvider, bool>(
      (provider) => provider.isSmall,
    );

    return ResponsiveLayout(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stay Obsessed.',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: textColor,
                    fontStyle: FontStyle.italic,
                  ),
            ),
            SizedBox(height: AppTheme.spacing4),
            Text(
              'Join our sensory newsletter for drops that defy the mainstream.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: textColor,
                  ),
            ),
            SizedBox(height: AppTheme.spacing6),
            if (isSmall)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: borderColor, width: AppTheme.borderWidth),
                        bottom: BorderSide(color: borderColor, width: AppTheme.borderWidth),
                        left: BorderSide(color: borderColor, width: AppTheme.borderWidth),
                      ),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'YOUR@EMAIL.COM',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(AppTheme.spacing4),
                      ),
                    ),
                  ),
                  SizedBox(height: AppTheme.spacing4),
                  NeoButton(
                    label: 'Join',
                    onPressed: () {},
                    backgroundColor: colors.black,
                    textColor: colors.white,
                    height: 56,
                    isFullWidth: true,
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: borderColor, width: AppTheme.borderWidth),
                          bottom: BorderSide(color: borderColor, width: AppTheme.borderWidth),
                          left: BorderSide(color: borderColor, width: AppTheme.borderWidth),
                        ),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'YOUR@EMAIL.COM',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(AppTheme.spacing4),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppTheme.spacing4),
                  SizedBox(
                    width: 140,
                    child: NeoButton(
                      label: 'Join',
                      onPressed: () {},
                      backgroundColor: colors.black,
                      textColor: colors.white,
                      height: 56,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
