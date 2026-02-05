import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../theme/app_theme.dart';
import '../../widgets/neo_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final borderColor =
        brightness == Brightness.light ? AppTheme.black : AppTheme.white;
    final isSmall = MediaQuery.of(context).size.width < 768;

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
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final googleProvider = GoogleAuthProvider();
      if (kIsWeb) {
        await _auth.signInWithPopup(googleProvider);
      } else {
        await _auth.signInWithProvider(googleProvider);
      }
    } on FirebaseAuthException catch (e) {
      _showError(_mapFirebaseError(e));
    } catch (e) {
      _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter email and password.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      _showError(_mapFirebaseError(e));
    } catch (_) {
      _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendPasswordReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showError('Enter your email above to reset password.');
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent.'),
        ),
      );
    } on FirebaseAuthException catch (e) {
      _showError(_mapFirebaseError(e));
    } catch (_) {
      _showError('Could not send reset email. Please try again.');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'account-exists-with-different-credential':
        return 'Account exists with a different sign-in method.';
      case 'popup-closed-by-user':
        return 'Sign-in popup was closed before completing.';
      default:
        return 'Authentication failed. Please try again.';
    }
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
    final bgColor =
        brightness == Brightness.light ? AppTheme.white : AppTheme.backgroundDark;

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
    final textColor =
        brightness == Brightness.light ? AppTheme.black : AppTheme.white;

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
            if (_isLoading) return;
            _signInWithGoogle();
          },
          backgroundColor: AppTheme.white,
          textColor: AppTheme.black,
          isFullWidth: true,
        ),
        SizedBox(height: AppTheme.spacing4),
        // Divider
        Row(
          children: [
            const Expanded(child: Divider(thickness: 2)),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
              child: Text(
                'OR USE EMAIL',
                style:
                    Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
              ),
            ),
            const Expanded(child: Divider(thickness: 2)),
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
              onTap: () => setState(() => _rememberMe = !_rememberMe),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _rememberMe
                          ? AppTheme.primaryYellow
                          : AppTheme.white,
                      border:
                          Border.all(color: AppTheme.black, width: 2),
                    ),
                    child: _rememberMe
                        ? Center(
                            child: Icon(Icons.check,
                                size: 16, color: AppTheme.black),
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
                if (_isLoading) return;
                _sendPasswordReset();
              },
              child: Text(
                'FORGOT PASSWORD?',
                style:
                    Theme.of(context).textTheme.labelSmall?.copyWith(
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
            if (_isLoading) return;
            _signInWithEmail();
          },
          isFullWidth: true,
        ),
        SizedBox(height: AppTheme.spacing4),
        // Go to Register (named route)
        GestureDetector(
          onTap: () {
            if (_isLoading) return;
            Navigator.of(context).pushReplacementNamed('/register');
          },
          child: Text(
            "Don't have an account? Create one",
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        SizedBox(height: AppTheme.spacing4),
        // Subtext
        Text(
          'By continuing, you agree to our Terms & Conditions and Privacy Policy.',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                height: 1.4,
              ),
        ),
      ],
    );
  }
}
