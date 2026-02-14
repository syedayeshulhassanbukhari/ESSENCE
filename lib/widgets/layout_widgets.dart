import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';
import '../providers/responsive_provider.dart';
import 'neo_widgets.dart';

// ===== APP HEADER =====
class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final textColor = brightness == Brightness.light ? AppTheme.black : AppTheme.white;
    // Discover.html nav: border is black; dark border is primary yellow
    final borderColor = brightness == Brightness.light ? AppTheme.black : AppTheme.primaryYellow;
    final isSmall = context.select<ResponsiveProvider, bool>(
      (provider) => provider.isSmall,
    );

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor, width: AppTheme.borderWidth)),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing4,
      ),
      child: Row(
        children: [
          Text(
            'ESSENCE.',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: textColor,
                  fontStyle: FontStyle.italic,
                  fontSize: isSmall ? 28 : 36,
                ),
          ),
          if (!isSmall) ...[
            SizedBox(width: AppTheme.spacing6),
            ..._buildNavButtons(context),
          ],
          const Spacer(),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return NeoIconButton(
                icon: themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                backgroundColor: themeProvider.isDarkMode
                    ? AppTheme.primaryYellow
                    : AppTheme.white,
                iconColor: themeProvider.isDarkMode
                    ? AppTheme.black
                    : AppTheme.black,
                onPressed: () => themeProvider.toggleDarkMode(),
              );
            },
          ),
          SizedBox(width: AppTheme.spacing2),
          const _UserProfileAvatar(),
        ],
      ),
    );
  }

  void _onNavTap(BuildContext context, String routeName) {
    final currentName = ModalRoute.of(context)?.settings.name;
    if (currentName == routeName) return;
    Navigator.of(context).pushReplacementNamed(routeName);
  }

  List<Widget> _buildNavButtons(BuildContext context) {
    final items = const [
      {'label': 'Home', 'route': '/home'},
      {'label': 'Discover', 'route': '/discover'},
      {'label': 'Marketplace', 'route': '/marketplace'},
    ];

    final navTextStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        );

    return items
        .map(
          (item) => Padding(
            padding: const EdgeInsets.only(right: AppTheme.spacing2),
            child: NeoButton(
              label: item['label'] as String,
              onPressed: () => _onNavTap(context, item['route'] as String),
              backgroundColor: AppTheme.white,
              textColor: AppTheme.black,
              height: 40,
              textStyle: navTextStyle,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing4,
              ),
            ),
          ),
        )
        .toList();
  }
}

class _UserProfileAvatar extends StatelessWidget {
  const _UserProfileAvatar();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final brightness = Theme.of(context).brightness;
    final borderColor =
        brightness == Brightness.light ? AppTheme.black : AppTheme.primaryYellow;
    final bgColor =
        brightness == Brightness.light ? AppTheme.white : AppTheme.zinc900;

    final photoUrl = user?.photoURL;
    final avatar = Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: AppTheme.borderWidth),
        boxShadow: [AppTheme.neoShadow(brightness, offset: AppTheme.shadowSmall)],
      ),
      child: Center(
        child: ClipOval(
          child: photoUrl != null && photoUrl.isNotEmpty
              ? Image.network(
                  photoUrl,
                  fit: BoxFit.cover,
                  width: 40,
                  height: 40,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.person,
                    color: brightness == Brightness.light
                        ? AppTheme.black
                        : AppTheme.white,
                    size: 24,
                  ),
                )
              : Icon(
                  Icons.person,
                  color:
                      brightness == Brightness.light ? AppTheme.black : AppTheme.white,
                  size: 24,
                ),
        ),
      ),
    );

    final displayName = user?.displayName?.isNotEmpty == true
        ? user!.displayName!
        : (user?.email ?? 'Signed in user');

    return PopupMenuButton<int>(
      tooltip: 'Account',
      offset: const Offset(0, 8),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: borderColor, width: AppTheme.borderWidth),
      ),
      onSelected: (value) {
        if (value == 1) {
          FirebaseAuth.instance.signOut();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<int>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<int>(
          value: 1,
          child: Row(
            children: [
              const Icon(Icons.logout, size: 18),
              const SizedBox(width: AppTheme.spacing2),
              Text(
                'Logout',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
      child: avatar,
    );
  }
}

// ===== APP FOOTER =====
class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    // Discover.html footer: light border black; dark border primary yellow
    final borderColor = brightness == Brightness.light ? AppTheme.black : AppTheme.primaryYellow;
    final isSmall = context.select<ResponsiveProvider, bool>(
      (provider) => provider.isSmall,
    );

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: borderColor, width: AppTheme.borderWidth)),
      ),
      padding: const EdgeInsets.all(AppTheme.spacing6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isSmall)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ESSENCE.',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                      SizedBox(height: AppTheme.spacing4),
                      Text(
                        'Disrupting the industry one molecule at a time. The revolution will smell incredible.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppTheme.spacing8),
                Expanded(
                  child: _buildFooterColumn(context, 'NAVIGATION', ['Archive', 'Wholesale', 'Collaborations', 'Careers']),
                ),
                SizedBox(width: AppTheme.spacing8),
                Expanded(
                  child: _buildFooterColumn(context, 'SOCIALS', ['Instagram', 'TikTok', 'Behance', 'Twitter']),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ESSENCE.',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                ),
                SizedBox(height: AppTheme.spacing4),
                Text(
                  'Disrupting the industry. The revolution will smell incredible.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          SizedBox(height: AppTheme.spacing6),
          Divider(thickness: AppTheme.borderWidth, color: borderColor),
          SizedBox(height: AppTheme.spacing4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '© 2024 ESSENCE FRAGRANCE LAB.',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
              ),
              if (!isSmall)
                Row(
                  children: [
                    _buildFooterLink(context, 'Privacy'),
                    SizedBox(width: AppTheme.spacing4),
                    _buildFooterLink(context, 'Terms'),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterColumn(BuildContext context, String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        SizedBox(height: AppTheme.spacing2),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacing2),
          child: _buildFooterLink(context, item),
        )),
      ],
    );
  }

  Widget _buildFooterLink(BuildContext context, String label) {
    return Text(
      label,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

// ===== RESPONSIVE LAYOUT =====
class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsets? padding;

  const ResponsiveLayout({
    required this.child,
    this.maxWidth = 1440,
    this.padding,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = context.select<ResponsiveProvider, bool>(
      (provider) => provider.isSmall,
    );

    final defaultPadding = isSmall
        ? const EdgeInsets.all(AppTheme.spacing4)
        : const EdgeInsets.all(AppTheme.spacing6);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? defaultPadding,
          child: child,
        ),
      ),
    );
  }
}

// ===== SECTION DIVIDER =====
class SectionDivider extends StatelessWidget {
  const SectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).brightness == Brightness.light ? AppTheme.black : AppTheme.primaryYellow;
    return Container(
      height: AppTheme.borderWidth,
      color: borderColor,
    );
  }
}
