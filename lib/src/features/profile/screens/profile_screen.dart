import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../repositories/profile_repository.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final subscriptionAsync = ref.watch(subscriptionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildProfileHeader(profileAsync),
            const SizedBox(height: 32),
            _buildSubscriptionCard(context, subscriptionAsync),
            const SizedBox(height: 32),
            _buildSettingsList(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(AsyncValue profileAsync) {
    return profileAsync.when(
      data: (profile) => Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.green,
            child: Icon(LucideIcons.user, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(profile.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(profile.email, style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildSubscriptionCard(BuildContext context, AsyncValue subAsync) {
    return subAsync.when(
      data: (sub) {
        final isPro = sub.tier == 'pro' || sub.tier == 'family';
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isPro ? [Colors.purple.shade700, Colors.deepPurple.shade900] : [Colors.grey.shade200, Colors.grey.shade300],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: isPro ? [BoxShadow(color: Colors.purple.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPro ? 'Pro Member' : 'Free Tier',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isPro ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isPro ? 'Thank you for supporting Cookest!' : 'Upgrade to Pro for unlimited features.',
                      style: TextStyle(
                        color: isPro ? Colors.white70 : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isPro)
                ElevatedButton(
                  onPressed: () => context.push('/paywall'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Upgrade'),
                ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox(),
    );
  }

  Widget _buildSettingsList(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _buildListTile(
          icon: LucideIcons.bell,
          title: 'Push Notifications',
          onTap: () {},
        ),
        _buildListTile(
          icon: LucideIcons.refreshCcw,
          title: 'Reset Taste Preferences',
          subtitle: 'Clears AI learned preferences',
          onTap: () async {
            try {
              await ref.read(profileRepositoryProvider).resetTastePreferences();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preferences reset successfully.')));
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            }
          },
        ),
        _buildListTile(
          icon: LucideIcons.lock,
          title: 'Change Password',
          onTap: () {},
        ),
        const Divider(),
        _buildListTile(
          icon: LucideIcons.logOut,
          title: 'Logout',
          textColor: Colors.red,
          onTap: () {
            ref.read(authProvider.notifier).logout();
          },
        ),
      ],
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Colors.grey.shade700),
      title: Text(title, style: TextStyle(color: textColor ?? Colors.black87, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(LucideIcons.chevronRight, size: 16),
      onTap: onTap,
    );
  }
}
