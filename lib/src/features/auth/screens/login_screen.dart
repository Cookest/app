import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cookest_ui/cookest_ui.dart';
import 'package:cookest/src/core/theme/app_colors.dart';
import '../../../core/storage/secure_storage.dart';
import '../providers/auth_provider.dart';
import '../repositories/auth_repository.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all fields.');
      return;
    }
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final token = await ref.read(authRepositoryProvider).login(email, password);
      ref.read(authProvider.notifier).setToken(token);
      await SecureStorage.setRememberMe(_rememberMe);
      if (_rememberMe) {
        await SecureStorage.saveAccessToken(token);
      } else {
        await SecureStorage.clearTokens();
      }
      if (!mounted) return;
      context.go('/');
    } catch (e) {
      setState(() { _errorMessage = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appSurface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 64, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(LucideIcons.chefHat, size: 48, color: CookestTokens.colorPrimaryDEFAULT),
            const SizedBox(height: 16),
            Text(
              'Welcome back',
              style: GoogleFonts.playfairDisplay(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: context.appHeading,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in to your Cookest account',
              style: GoogleFonts.inter(fontSize: 16, color: context.appMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            if (_errorMessage != null) ...[
              CkAlert(
                variant: CkAlertVariant.error,
                title: 'Sign in failed',
                dismissible: true,
                onDismiss: () => setState(() => _errorMessage = null),
                child: Text(_errorMessage!),
              ),
              const SizedBox(height: 16),
            ],
            CkInput(
              controller: _emailController,
              label: 'Email',
              placeholder: 'you@example.com',
              iconLeft: const Icon(LucideIcons.mail, size: 16),
              keyboardType: TextInputType.emailAddress,
              fullWidth: true,
            ),
            const SizedBox(height: 16),
            CkInput(
              controller: _passwordController,
              label: 'Password',
              placeholder: '••••••••',
              iconLeft: const Icon(LucideIcons.lock, size: 16),
              obscureText: true,
              fullWidth: true,
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => setState(() => _rememberMe = !_rememberMe),
              child: Row(
                children: [
                  CkCheckbox(
                    value: _rememberMe,
                    onChanged: (v) => setState(() => _rememberMe = v),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Remember me',
                    style: GoogleFonts.inter(color: context.appMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CkButton(
              onPressed: _submit,
              loading: _isLoading,
              fullWidth: true,
              size: CkButtonSize.lg,
              child: const Text('Sign in'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? "),
                CkButton(
                  variant: CkButtonVariant.ghost,
                  size: CkButtonSize.sm,
                  onPressed: () => context.push('/register'),
                  child: const Text('Sign up'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
