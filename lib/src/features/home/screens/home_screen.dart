import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../meal_plan/repositories/meal_plan_repository.dart';
import '../../meal_plan/models/meal_plan.dart';
import '../../pantry/repositories/inventory_repository.dart';
import '../../../shared/theme/shadcn_theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealPlanAsync = ref.watch(currentMealPlanProvider);
    final expiringCountAsync = ref.watch(expiringCountProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              _buildHeader(context),
              const SizedBox(height: 28),
              _buildSectionLabel(context, 'What\'s cooking right now?', showViewAll: true, onViewAll: () => context.go('/meals')),
              const SizedBox(height: 16),
              mealPlanAsync.when(
                data: (plan) => _buildFeaturedCard(context, plan),
                loading: () => _buildFeaturedCardPlaceholder(),
                error: (_, __) => _buildFeaturedCardPlaceholder(),
              ),
              const SizedBox(height: 16),
              expiringCountAsync.when(
                data: (count) => count > 0 ? _buildAlertStrip(context, count) : const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),
              _buildHostingRow(context),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            '${_greeting()}, Chef',
            style: GoogleFonts.playfairDisplay(
              fontSize: 26,
              fontWeight: FontWeight.normal,
              color: AppTheme.darkGreen,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => context.push('/profile'),
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppTheme.sage,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                'C',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.surface,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label, {bool showViewAll = false, VoidCallback? onViewAll}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          label,
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.normal,
            color: AppTheme.darkGreen,
          ),
        ),
        if (showViewAll) ...[
          const Spacer(),
          GestureDetector(
            onTap: onViewAll,
            child: Text(
              'View all',
              style: GoogleFonts.inter(fontSize: 13, color: AppTheme.sage),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFeaturedCard(BuildContext context, MealPlan? plan) {
    final today = DateTime.now().weekday - 1;
    MealSlot? featuredSlot;
    if (plan != null) {
      final todaySlots = plan.slots.where((s) => s.dayOfWeek == today && s.recipe != null).toList();
      if (todaySlots.isNotEmpty) featuredSlot = todaySlots.first;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [AppTheme.cardShadow],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180,
            width: double.infinity,
            color: const Color(0xFFE8F0E4),
            child: Center(
              child: Icon(LucideIcons.utensils, size: 48, color: AppTheme.sage.withOpacity(0.4)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  featuredSlot?.recipe?.name ?? 'No recipe planned today',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: AppTheme.darkGreen,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(LucideIcons.clock, size: 14, color: AppTheme.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      featuredSlot?.recipe != null ? '${featuredSlot!.recipe!.totalTimeMin} mins' : '—',
                      style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted),
                    ),
                    const SizedBox(width: 12),
                    Icon(LucideIcons.star, size: 14, color: AppTheme.textMuted),
                    const SizedBox(width: 4),
                    Text('4.0', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: featuredSlot?.recipe != null
                            ? () => context.push('/recipes/${featuredSlot!.recipe!.id}')
                            : null,
                        child: Text('Cook it!', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: featuredSlot?.recipe != null
                          ? () => context.push('/recipes/${featuredSlot!.recipe!.id}')
                          : null,
                      style: TextButton.styleFrom(foregroundColor: AppTheme.sage),
                      child: Text('View details', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.sage)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCardPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [AppTheme.cardShadow],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            height: 180,
            width: double.infinity,
            color: const Color(0xFFE8F0E4),
            child: Center(
              child: Icon(LucideIcons.utensils, size: 48, color: AppTheme.sage.withOpacity(0.4)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No recipe planned today',
                  style: GoogleFonts.playfairDisplay(fontSize: 18, color: AppTheme.darkGreen),
                ),
                const SizedBox(height: 8),
                Text(
                  'Set up your meal plan to see today\'s recipe here.',
                  style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted, height: 1.5),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: null,
                  child: Text('Cook it!', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertStrip(BuildContext context, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.amberLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.alertTriangle, size: 16, color: AppTheme.amber),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$count item${count == 1 ? '' : 's'} expiring soon',
              style: GoogleFonts.inter(fontSize: 13, color: AppTheme.amber),
            ),
          ),
          GestureDetector(
            onTap: () => context.go('/pantry'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.amber,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Use it',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHostingRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Hosting a meal?',
            style: GoogleFonts.inter(fontSize: 15, color: AppTheme.darkGreen),
          ),
        ),
        OutlinedButton(
          onPressed: () => context.go('/meals'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.sage,
            side: const BorderSide(color: AppTheme.sage),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: Text('Plan it', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.sage)),
        ),
      ],
    );
  }
}
