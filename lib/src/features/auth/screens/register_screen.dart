import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cookest_ui/cookest_ui.dart';
import '../providers/auth_provider.dart';
import '../repositories/auth_repository.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all fields.');
      return;
    }
    if (password.length < 8) {
      setState(() => _errorMessage = 'Password must be at least 8 characters.');
      return;
    }
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      await ref.read(authRepositoryProvider).register(email, password, name);
      final token = await ref.read(authRepositoryProvider).login(email, password);
      ref.read(authProvider.notifier).setToken(token);
      if (mounted) context.go('/onboarding');
    } catch (e) {
      setState(() { _errorMessage = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 64, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(LucideIcons.chefHat, size: 48, color: CookestTokens.colorPrimaryDEFAULT),
            const SizedBox(height: 16),
            Text(
              'Create account',
              style: GoogleFonts.playfairDisplay(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: CookestTokens.colorHeadingLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Join thousands of home cooks',
              style: GoogleFonts.inter(fontSize: 16, color: CookestTokens.colorMutedLight),
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
              controller: _nameController,
              label: 'Name',
              placeholder: 'Your full name',
              iconLeft: const Icon(LucideIcons.user, size: 16),
              fullWidth: true,
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 24),
            CkButton(
              onPressed: _submit,
              loading: _isLoading,
              fullWidth: true,
              size: CkButtonSize.lg,
              child: const Text('Create account'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Already have an account? '),
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Sign in'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
