import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../widgets/neo_widgets.dart';
import '../../providers/auth_ui_provider.dart';
import '../../providers/responsive_provider.dart';
import '../../providers/auth_controller.dart';
import '../../providers/theme_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthUiProvider(),
      child: Builder(
        builder: (context) {
          final brightness = Theme.of(context).brightness;
          final colors = context.watch<ThemeProvider>().colors;
          final borderColor =
              brightness == Brightness.light ? colors.black : colors.white;
          final isSmall = context.select<ResponsiveProvider, bool>(
            (provider) => provider.isSmall,
          );

          return Scaffold(
            backgroundColor: colors.backgroundLight,
            body: isSmall
                ? _buildMobileLayout(context)
                : Row(
                    children: [
                      // Left Side - Image Section (same as login)
                      Expanded(
                        flex: 5,
                        child: Container(
                          decoration: BoxDecoration(
                            color: colors.black,
                            border: Border(
                              right: BorderSide(
                                color: borderColor,
                                width: AppTheme.borderWidth,
                              ),
                            ),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBMdvwApHp3zBcymz7XT6oxbymkrSmImhI4gx9HzcYnEAu_xPQUXVUC-8nHfDStJb9efKpy_-I_VBu3yvqRvbQgo1CYIq_5gOdoQCoUYCHJIiN_9haWb-N_jLYkB4x7X-qZ94Mj4KUCECCYqHNaquj-78e92lQO5v2jyy8y9Kk3GHYRrx0Zew1st7_pHHcrP6S9MEqOD5ryTRjaDSumeuqb7E_-KU75w3kTNaCtmNLzSqllSxXt8Wq35R4foDwI7sg0jbtF4rULGmo',
                                    fit: BoxFit.cover,
                                  ),
                                  IgnorePointer(
                                    child: Opacity(
                                      opacity: 0.2,
                                      child: Image.network(
                                        'https://lh3.googleusercontent.com/aida-public/AB6AXuDUZ1K6kRs0xs46m6YbFvvL9cXvZBVmBvEw_ZKcNsws0lWdcBOQRmBsUb0BiwzNZK-7Rmt0vnU3TYd_yfmN9K2Nrtxzs8L2Q6-r56VSteXSMv1d3b_Cy4MZB-3ApA1Eaz0G7L_YLx177TMZ-QEmapj_Pffh9Gje6fWuO1v2H-YplxBlhnVKBnCRJS-ykuQNm0t3Sy5cPV6jFSwWhPdKAyer75oEI91dnCuNI0Xw4_VLAFK_9a6h7Jx6w1zydhi7LmccGkwL91UBPHQ',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // Logo
                              Positioned(
                                top: AppTheme.spacing4,
                                left: AppTheme.spacing4,
                                child: NeoCard(
                                  backgroundColor: colors.white,
                                  shadow: true,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.flare, color: colors.black),
                                      SizedBox(width: AppTheme.spacing2),
                                      Text(
                                        'ESSENCE',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              color: colors.black,
                                              fontWeight: FontWeight.w900,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Bottom Tag
                              Positioned(
                                bottom: AppTheme.spacing4,
                                left: AppTheme.spacing4,
                                child: NeoCard(
                                  backgroundColor: colors.primaryYellow,
                                  shadow: true,
                                  child: Text(
                                    'Join the Vault',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          color: colors.black,
                                          fontStyle: FontStyle.italic,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Right Side - Register Form
                      Expanded(
                        flex: 7,
                        child: _buildRegisterForm(context),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Future<void> _registerWithEmail(BuildContext context) async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showError('Please enter name, email and password.');
      return;
    }

    final ui = context.read<AuthUiProvider>();
    ui.setLoading(true);
    try {
      final error = await context.read<AuthController>().registerWithEmail(
            name: name,
            email: email,
            password: password,
          );
      if (error != null) {
        _showError(error);
      }
    } finally {
      if (!mounted) return;
      ui.setLoading(false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppTheme.spacing4),
            NeoCard(
              backgroundColor: colors.black,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.flare, color: colors.white),
                  SizedBox(width: AppTheme.spacing2),
                  Text(
                    'ESSENCE',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppTheme.spacing8),
            _buildRegisterFormContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterForm(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final colors = context.watch<ThemeProvider>().colors;
    final bgColor =
      brightness == Brightness.light ? colors.white : colors.backgroundDark;

    return Container(
      color: bgColor,
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacing6,
              vertical: AppTheme.spacing8,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: _buildRegisterFormContent(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterFormContent(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final colors = context.watch<ThemeProvider>().colors;
    final textColor =
      brightness == Brightness.light ? colors.black : colors.white;
    final ui = context.watch<AuthUiProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heading
        Text(
          'Create\nYour Vault',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: textColor,
                height: 0.9,
              ),
        ),
        SizedBox(height: AppTheme.spacing2),
        NeoCard(
          backgroundColor: colors.primaryYellow,
          padding: const EdgeInsets.all(AppTheme.spacing4),
          shadow: false,
          child: Text(
            'Register to start curating your signature scent collection.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colors.black,
                ),
          ),
        ),
        SizedBox(height: AppTheme.spacing6),
        // Name Input
        NeoInput(
          label: 'Full Name',
          placeholder: 'YOUR NAME',
          controller: _nameController,
        ),
        SizedBox(height: AppTheme.spacing4),
        // Email Input
        NeoInput(
          label: 'Email Address',
          placeholder: 'YOUR@EMAIL.COM',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: AppTheme.spacing4),
        // Password Input
        NeoInput(
          label: 'Password',
          placeholder: '••••••••',
          controller: _passwordController,
          obscureText: true,
        ),
        SizedBox(height: AppTheme.spacing6),
        // Register Button
        NeoButton(
          label: 'Create Account',
          onPressed: () {
            if (ui.isLoading) return;
            _registerWithEmail(context);
          },
          isFullWidth: true,
          isLoading: ui.isLoading,
        ),
        SizedBox(height: AppTheme.spacing4),
        // Go to Login (named route)
        GestureDetector(
          onTap: () {
            if (ui.isLoading) return;
            Navigator.of(context).pushReplacementNamed('/login');
          },
          child: Text(
            'Already have an account? Sign in',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        SizedBox(height: AppTheme.spacing4),
        // Subtext
        Text(
          'By creating an account, you agree to our Terms & Conditions and Privacy Policy.',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                height: 1.4,
              ),
        ),
      ],
    );
  }
}
