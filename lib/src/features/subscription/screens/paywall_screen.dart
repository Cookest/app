import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _isLoading = false;

  Future<void> _checkout(String tier) async {
    setState(() => _isLoading = true);
    try {
      final response = await ref.read(dioProvider).post('/api/subscription/checkout', data: {'tier': tier});
      final url = response.data['url'];
      if (context.mounted) {
        // In a real app, we would use url_launcher to open this URL
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Redirecting to Stripe checkout: $url')));
        context.pop();
      }
    } on DioException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.response?.data['error'] ?? e.message}')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.x, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(LucideIcons.crown, size: 64, color: Colors.purple),
              const SizedBox(height: 24),
              Text(
                'Unlock Cookest Pro',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Get unlimited AI chat, price comparison, recipe creation, and more.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              _buildFeatureRow('Unlimited AI Chat limits'),
              _buildFeatureRow('Shopping List Price Optimizer'),
              _buildFeatureRow('Create and share custom recipes'),
              _buildFeatureRow('Advanced AI taste learning'),
              
              const SizedBox(height: 48),
              
              _buildTierCard(
                title: 'Pro',
                price: '€9.99',
                period: '/month',
                description: 'Perfect for individuals.',
                onTap: () => _checkout('pro'),
                isPopular: true,
              ),
              
              const SizedBox(height: 16),
              
              _buildTierCard(
                title: 'Family',
                price: '€14.99',
                period: '/month',
                description: 'Share with up to 5 family members.',
                onTap: () => _checkout('family'),
                isPopular: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          const Icon(LucideIcons.checkCircle2, color: Colors.purple),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildTierCard({
    required String title,
    required String price,
    required String period,
    required String description,
    required VoidCallback onTap,
    required bool isPopular,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isPopular ? const BorderSide(color: Colors.purple, width: 2) : BorderSide.none,
      ),
      elevation: isPopular ? 4 : 1,
      child: InkWell(
        onTap: _isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isPopular)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.purple.shade100, borderRadius: BorderRadius.circular(8)),
                  child: Text('MOST POPULAR', style: TextStyle(color: Colors.purple.shade800, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: price, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                        TextSpan(text: period, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(description, style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
        ),
      ),
    );
  }
}
