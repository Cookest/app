import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cookest_ui/cookest_ui.dart';
import '../repositories/profile_repository.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    
    ref.read(authProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final subscriptionAsync = ref.watch(subscriptionProvider);

    return Scaffold(
      backgroundColor: CookestTokens.colorBackgroundLight,
      appBar: AppBar(
        backgroundColor: CookestTokens.colorBackgroundLight,
        elevation: 0,
        title: Text(
          'Profile',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: CookestTokens.colorHeadingLight,
          ),
        ),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CkSpinner()),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: CkAlert(
            variant: CkAlertVariant.error,
            child: Text('Failed to load profile: $e'),
          ),
        ),
        data: (profile) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
          child: Column(
            children: [
              Center(
                child: CkAvatar(
                  alt: profile.name,
                  size: CkAvatarSize.xl,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  profile.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: CookestTokens.colorHeadingLight,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Center(
                child: Text(
                  profile.email,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: CookestTokens.colorMutedLight,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              subscriptionAsync.maybeWhen(
                data: (sub) {
                  final isPro = sub.tier == 'pro' || sub.tier == 'family';
                  return Center(
                    child: CkBadge(
                      variant: isPro
                          ? CkBadgeVariant.success
                          : CkBadgeVariant.standard,
                      child: Text(sub.tier.toUpperCase()),
                    ),
                  );
                },
                orElse: () => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),
              CkCard(
                padding: CkCardPadding.md,
                child: Column(
                  children: [
                    _buildSettingsRow(
                      context,
                      icon: LucideIcons.user,
                      label: 'Edit Profile',
                      onTap: () {},
                    ),
                    Divider(color: CookestTokens.colorBorderLight, height: 1),
                    _buildSettingsRow(
                      context,
                      icon: LucideIcons.bell,
                      label: 'Notifications',
                      onTap: () {},
                    ),
                    Divider(color: CookestTokens.colorBorderLight, height: 1),
                    _buildSettingsRow(
                      context,
                      icon: LucideIcons.crown,
                      label: 'Upgrade',
                      onTap: () => context.push('/paywall'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              CkButton(
                variant: CkButtonVariant.danger,
                fullWidth: true,
                onPressed: () => _logout(context, ref),
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: CookestTokens.colorMutedLight),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: CookestTokens.colorHeadingLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(LucideIcons.chevronRight,
                size: 16, color: CookestTokens.colorMutedLight),
          ],
        ),
      ),
    );
  }
}
