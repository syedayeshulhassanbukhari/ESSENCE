import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';
import '../providers/responsive_provider.dart';
import '../routing/app_router.dart';
import 'neo_widgets.dart';

// ===== APP HEADER =====
class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  Future<void> _onUploadTap(BuildContext context) async {
    context.read<AppRouter>().replaceWithFade('/admin');
  }

  void _onMobileMenuSelected(BuildContext context, String value) {
    switch (value) {
      case '/home':
      case '/discover':
      case '/marketplace':
        _onNavTap(context, value);
        return;
      case 'upload':
        _onUploadTap(context);
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final brightness = Theme.of(context).brightness;
    final textColor =
      brightness == Brightness.light ? colors.black : colors.white;
    // Discover.html nav: border is black; dark border is primary yellow
    final borderColor =
      brightness == Brightness.light ? colors.black : colors.primaryYellow;
    final isSmall = context.select<ResponsiveProvider, bool>(
      (provider) => provider.isSmall,
    );

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: borderColor,
            width: AppTheme.navBarBorderWidth,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacing4.w,
        vertical: AppTheme.navBarVerticalPadding.h,
      ),
      child: Row(
        children: [
          Text(
            'ESSENCE.',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: textColor,
                  fontStyle: FontStyle.italic,
                  fontSize: (isSmall
                          ? AppTheme.navBrandFontSmall
                          : AppTheme.navBrandFontLarge)
                      .sp,
                ),
          ),
          const Spacer(),
          if (!isSmall) ...[
            ..._buildNavButtons(context),
            SizedBox(width: AppTheme.spacing2.w),
            _NavBarButton(
              label: 'Upload Your Perfume',
              isActive: true,
              onPressed: () => _onUploadTap(context),
            ),
          ],
          if (isSmall)
            PopupMenuButton<String>(
              tooltip: 'Menu',
              onSelected: (value) => _onMobileMenuSelected(context, value),
              itemBuilder: (context) => const [
                PopupMenuItem<String>(
                  value: '/home',
                  child: Text('Home'),
                ),
                PopupMenuItem<String>(
                  value: '/discover',
                  child: Text('Discover'),
                ),
                PopupMenuItem<String>(
                  value: '/marketplace',
                  child: Text('Marketplace'),
                ),
                PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'upload',
                  child: Text('Upload Your Perfume'),
                ),
              ],
              icon: Icon(
                Icons.menu,
                color: textColor,
                size: AppTheme.navMenuIconSize.sp,
              ),
            ),
          SizedBox(width: AppTheme.spacing2.w),
          const _UserProfileAvatar(),
        ],
      ),
    );
  }

  void _onNavTap(BuildContext context, String routeName) {
    final currentName = ModalRoute.of(context)?.settings.name;
    if (currentName == routeName) return;
    context.read<AppRouter>().replaceWithFade(routeName);
  }

  List<Widget> _buildNavButtons(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final items = const [
      {'label': 'Home', 'route': '/home'},
      {'label': 'Discover', 'route': '/discover'},
      {'label': 'Marketplace', 'route': '/marketplace'},
    ];

    return items
        .map(
          (item) => Padding(
            padding: EdgeInsets.only(right: AppTheme.spacing2.w),
            child: _NavBarButton(
              label: item['label'] as String,
              isActive: currentRoute == item['route'],
              onPressed: () => _onNavTap(context, item['route'] as String),
            ),
          ),
        )
        .toList();
  }
}

class _NavBarButton extends StatefulWidget {
  const _NavBarButton({
    required this.label,
    required this.onPressed,
    required this.isActive,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isActive;

  @override
  State<_NavBarButton> createState() => _NavBarButtonState();
}

class _NavBarButtonState extends State<_NavBarButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final brightness = Theme.of(context).brightness;
    final borderColor =
        brightness == Brightness.light ? colors.black : colors.primaryYellow;
    final bgColor = widget.isActive ? colors.primaryYellow : colors.white;
    final textColor = colors.black;
    final shadow = _isPressed
        ? <BoxShadow>[]
        : [
            BoxShadow(
              color: borderColor,
              offset: Offset(
                AppTheme.navButtonShadowOffset,
                AppTheme.navButtonShadowOffset,
              ),
              blurRadius: 0,
              spreadRadius: 0,
            )
          ];

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        height: AppTheme.navButtonHeight.h,
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.navButtonHorizontalPadding.w,
          vertical: AppTheme.navButtonVerticalPadding.h,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(
            color: borderColor,
            width: AppTheme.navBarBorderWidth,
          ),
          boxShadow: shadow,
        ),
        child: Center(
          child: Text(
            widget.label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                  letterSpacing: AppTheme.navButtonLetterSpacing,
                  fontSize: AppTheme.navButtonFontSize.sp,
                ),
          ),
        ),
      ),
    );
  }
}

class _UserProfileAvatar extends StatelessWidget {
  const _UserProfileAvatar();

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final isDarkMode = context.select<ThemeProvider, bool>(
      (provider) => provider.isDarkMode,
    );
    final themeProvider = context.read<ThemeProvider>();
    User? user;
    try {
      user = FirebaseAuth.instance.currentUser;
    } catch (_) {
      user = null;
    }
    final brightness = Theme.of(context).brightness;
    final borderColor =
      brightness == Brightness.light ? colors.black : colors.primaryYellow;
    final bgColor =
      brightness == Brightness.light ? colors.white : colors.zinc900;

    final photoUrl = user?.photoURL;
    final avatar = Container(
      width: AppTheme.navAvatarSize.w,
      height: AppTheme.navAvatarSize.w,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: AppTheme.borderWidth),
        boxShadow: [
          AppTheme.neoShadow(colors, brightness, offset: AppTheme.shadowSmall),
        ],
      ),
      child: Center(
        child: ClipOval(
          child: photoUrl != null && photoUrl.isNotEmpty
              ? Image.network(
                  photoUrl,
                  fit: BoxFit.cover,
                  width: AppTheme.navAvatarInnerSize.w,
                  height: AppTheme.navAvatarInnerSize.w,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.person,
                    color: brightness == Brightness.light
                        ? colors.black
                        : colors.white,
                    size: AppTheme.navAvatarIconSize.sp,
                  ),
                )
              : Icon(
                  Icons.person,
                  color: brightness == Brightness.light
                      ? colors.black
                      : colors.white,
                  size: AppTheme.navAvatarIconSize.sp,
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
          themeProvider.toggleDarkMode();
          return;
        }
        if (value == 2) {
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
              Icon(
                isDarkMode ? Icons.light_mode : Icons.dark_mode,
                size: 18,
              ),
              const SizedBox(width: AppTheme.spacing2),
              Text(
                isDarkMode ? 'Light Mode' : 'Dark Mode',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
        PopupMenuItem<int>(
          value: 2,
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
    final colors = context.watch<ThemeProvider>().colors;
    final brightness = Theme.of(context).brightness;
    // Discover.html footer: light border black; dark border primary yellow
    final borderColor =
        brightness == Brightness.light ? colors.black : colors.primaryYellow;
    final isSmall = context.select<ResponsiveProvider, bool>(
      (provider) => provider.isSmall,
    );

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: borderColor, width: AppTheme.borderWidth)),
      ),
      padding: EdgeInsets.all(AppTheme.spacing6.w),
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
                      SizedBox(height: AppTheme.spacing4.h),
                      Text(
                        'Disrupting the industry one molecule at a time. The revolution will smell incredible.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppTheme.spacing8.w),
                Expanded(
                  child: _buildFooterColumn(context, 'NAVIGATION', ['Archive', 'Wholesale', 'Collaborations', 'Careers']),
                ),
                SizedBox(width: AppTheme.spacing8.w),
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
                SizedBox(height: AppTheme.spacing4.h),
                Text(
                  'Disrupting the industry. The revolution will smell incredible.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          SizedBox(height: AppTheme.spacing6.h),
          Divider(thickness: AppTheme.borderWidth, color: borderColor),
          SizedBox(height: AppTheme.spacing4.h),
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
                    SizedBox(width: AppTheme.spacing4.w),
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
        SizedBox(height: AppTheme.spacing2.h),
        ...items.map((item) => Padding(
          padding: EdgeInsets.only(bottom: AppTheme.spacing2.h),
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
      ? EdgeInsets.all(AppTheme.spacing4.w)
      : EdgeInsets.all(AppTheme.spacing6.w);

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
    final colors = context.watch<ThemeProvider>().colors;
    final borderColor = Theme.of(context).brightness == Brightness.light
        ? colors.black
        : colors.primaryYellow;
    return Container(
      height: AppTheme.borderWidth,
      color: borderColor,
    );
  }
}
