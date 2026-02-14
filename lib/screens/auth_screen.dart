import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/neo_widgets.dart';
import '../providers/auth_ui_provider.dart';
import '../providers/responsive_provider.dart';
import '../providers/auth_controller.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthUiProvider(),
      child: Builder(
        builder: (context) {
          final brightness = Theme.of(context).brightness;
          final borderColor =
              brightness == Brightness.light ? AppTheme.black : AppTheme.white;
          final isSmall = context.select<ResponsiveProvider, bool>(
            (provider) => provider.isSmall,
          );

          return Scaffold(
            backgroundColor: AppTheme.backgroundLight,
            body: isSmall
                ? _buildMobileLayout(context)
                : Row(
                    children: [
                      // Left Side - Image Section
                      Expanded(
                        flex: 5,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.black,
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
                              // Background image + grainy overlay (from auth.html)
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
                                  backgroundColor: AppTheme.white,
                                  shadow: true,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.flare, color: AppTheme.black),
                                      SizedBox(width: AppTheme.spacing2),
                                      Text(
                                        'ESSENCE',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              color: AppTheme.black,
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
                                  backgroundColor: AppTheme.primaryYellow,
                                  shadow: true,
                                  child: Text(
                                    'Scents for the Bold',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          color: AppTheme.black,
                                          fontStyle: FontStyle.italic,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Right Side - Login Form
                      Expanded(
                        flex: 7,
                        child: _buildLoginForm(context),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    final ui = context.read<AuthUiProvider>();
    ui.setLoading(true);
    try {
      final error = await context.read<AuthController>().signInWithGoogle();
      if (error != null) {
        _showError(error);
      }
    } finally {
      if (!mounted) return;
      ui.setLoading(false);
    }
  }

  Future<void> _signInWithEmail(BuildContext context) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter email and password.');
      return;
    }

    final ui = context.read<AuthUiProvider>();
    ui.setLoading(true);
    try {
      final error = await context.read<AuthController>().signInWithEmail(
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

  Future<void> _sendPasswordReset(BuildContext context) async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showError('Enter your email above to reset password.');
      return;
    }

    final error =
        await context.read<AuthController>().sendPasswordReset(email);
    if (!mounted) return;
    if (error != null) {
      _showError(error);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password reset email sent.'),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppTheme.spacing4),
            NeoCard(
              backgroundColor: AppTheme.black,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.flare, color: AppTheme.white),
                  SizedBox(width: AppTheme.spacing2),
                  Text(
                    'ESSENCE',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.white,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppTheme.spacing8),
            _buildLoginFormContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bgColor = brightness == Brightness.light ? AppTheme.white : AppTheme.backgroundDark;

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
              child: _buildLoginFormContent(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginFormContent(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final textColor = brightness == Brightness.light ? AppTheme.black : AppTheme.white;
    final ui = context.watch<AuthUiProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heading
        Text(
          'Enter\nThe Void',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: textColor,
                height: 0.9,
              ),
        ),
        SizedBox(height: AppTheme.spacing2),
        NeoCard(
          backgroundColor: AppTheme.primaryYellow,
          padding: const EdgeInsets.all(AppTheme.spacing4),
          shadow: false,
          child: Text(
            'Login to access your exclusive perfume vault.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.black,
            ),
          ),
        ),
        SizedBox(height: AppTheme.spacing6),
        // Google Login Button
        NeoButton(
          label: 'Continue with Google',
          onPressed: () {
            if (ui.isLoading) return;
            _signInWithGoogle(context);
          },
          backgroundColor: AppTheme.white,
          textColor: AppTheme.black,
          isFullWidth: true,
        ),
        SizedBox(height: AppTheme.spacing4),
        // Divider
        Row(
          children: [
            Expanded(child: Divider(thickness: 2)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
              child: Text(
                'OR USE EMAIL',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            Expanded(child: Divider(thickness: 2)),
          ],
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
        SizedBox(height: AppTheme.spacing4),
        // Remember & Forgot
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => context.read<AuthUiProvider>().toggleRememberMe(),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: ui.rememberMe ? AppTheme.primaryYellow : AppTheme.white,
                      border: Border.all(color: AppTheme.black, width: 2),
                    ),
                    child: ui.rememberMe
                        ? Center(
                            child: Icon(Icons.check, size: 16, color: AppTheme.black),
                          )
                        : null,
                  ),
                  SizedBox(width: AppTheme.spacing2),
                  Text(
                    'REMEMBER ME',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                if (ui.isLoading) return;
                _sendPasswordReset(context);
              },
              child: Text(
                'FORGOT PASSWORD?',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      decoration: TextDecoration.underline,
                    ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppTheme.spacing6),
        // Sign In Button
        NeoButton(
          label: 'Sign In',
          onPressed: () {
            if (ui.isLoading) return;
            _signInWithEmail(context);
          },
          backgroundColor: AppTheme.primaryYellow,
          textColor: AppTheme.black,
          isFullWidth: true,
          isLoading: ui.isLoading,
        ),
        SizedBox(height: AppTheme.spacing4),
        // Register Link
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Don\'t have an account? ',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'Register Now',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppTheme.spacing8),
        // Footer Links
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {},
              child: Text(
                'Privacy Policy',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Text(
                'Terms of Service',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
