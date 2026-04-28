import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../meal_plan/repositories/meal_plan_repository.dart';
import '../../meal_plan/models/meal_plan.dart';
import '../../pantry/repositories/inventory_repository.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealPlanAsync = ref.watch(currentMealPlanProvider);
    final expiringCountAsync = ref.watch(expiringCountProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Cookest', style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold)),
              background: Container(color: Colors.white),
            ),
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(LucideIcons.bell)),
              const CircleAvatar(radius: 16, child: Icon(Icons.person, size: 20)),
              const SizedBox(width: 16),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsRow(expiringCountAsync),
                  const SizedBox(height: 24),
                  Text('Today\'s Meals', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  mealPlanAsync.when(
                    data: (plan) => _buildTodayMeals(context, plan),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                  ),
                  const SizedBox(height: 24),
                  Text('Nutrition Progress', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildNutritionProgress(),
                  const SizedBox(height: 24),
                  _buildQuickActions(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(AsyncValue<int> expiringCountAsync) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Expiring',
            expiringCountAsync.when(data: (c) => '$c', loading: () => '...', error: (_, __) => '0'),
            LucideIcons.alertTriangle,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('Streak', '5', LucideIcons.flame, Colors.red),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('Saved', '€12.40', LucideIcons.wallet, Colors.green),
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 12, color: color.withOpacity(0.8))),
        ],
      ),
    );
  }

  Widget _buildTodayMeals(BuildContext context, MealPlan? plan) {
    if (plan == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            const Text('No active meal plan found.'),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () {}, child: const Text('Generate Weekly Plan')),
          ],
        ),
      );
    }

    final today = DateTime.now().weekday - 1; // 0-6
    final todaySlots = plan.slots.where((s) => s.dayOfWeek == today).toList();

    return Column(
      children: todaySlots.map((slot) => _buildMealCard(context, slot)).toList(),
    );
  }

  Widget _buildMealCard(BuildContext context, MealSlot slot) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
          child: Center(child: Text(slot.mealType[0].toUpperCase(), style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold))),
        ),
        title: Text(slot.recipe?.name ?? (slot.isFlex ? 'Flex: ${slot.flexType}' : 'No recipe selected'), style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${slot.mealType[0].toUpperCase()}${slot.mealType.substring(1)} • ${slot.servings} servings'),
        trailing: slot.isCompleted 
            ? const Icon(Icons.check_circle, color: Colors.green)
            : Checkbox(value: false, onChanged: (v) {}),
      ),
    ).animate().fadeIn().slideX(begin: 0.05);
  }

  Widget _buildNutritionProgress() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        children: [
          _buildProgressBar('Calories', 0.7, Colors.green),
          const SizedBox(height: 12),
          _buildProgressBar('Protein', 0.4, Colors.blue),
          const SizedBox(height: 12),
          _buildProgressBar('Carbs', 0.8, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            Text('${(value * 100).toInt()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(value: value, backgroundColor: color.withOpacity(0.1), valueColor: AlwaysStoppedAnimation(color), minHeight: 6),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildActionButton(LucideIcons.plus, 'Add to Pantry', () {}),
        _buildActionButton(LucideIcons.search, 'Find Recipes', () {}),
        _buildActionButton(LucideIcons.messageSquare, 'AI Chat', () => context.push('/chat')),
        _buildActionButton(LucideIcons.settings, 'Settings', () {}),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
