import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../repositories/meal_plan_repository.dart';
import '../models/meal_plan.dart';

class MealPlanScreen extends ConsumerStatefulWidget {
  const MealPlanScreen({super.key});

  @override
  ConsumerState<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends ConsumerState<MealPlanScreen> {
  int _selectedDay = DateTime.now().weekday - 1; // 0=Mon, 6=Sun
  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final planAsync = ref.watch(currentMealPlanProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Plan', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(LucideIcons.listPlus), onPressed: () {}),
          IconButton(icon: const Icon(LucideIcons.pieChart), onPressed: () {}),
        ],
      ),
      body: planAsync.when(
        data: (plan) {
          if (plan == null) {
            return _buildEmptyState();
          }
          return Column(
            children: [
              _buildDaySelector(),
              Expanded(
                child: _buildDaySlots(plan),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.calendarX, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 24),
            Text('No active meal plan', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('Generate an AI-powered meal plan based on your inventory and preferences.', textAlign: TextAlign.center),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _generatePlan(),
              icon: const Icon(LucideIcons.wand2),
              label: const Text('Generate Weekly Plan'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generatePlan() async {
    try {
      await ref.read(mealPlanRepositoryProvider).generatePlan();
      ref.invalidate(currentMealPlanProvider);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to generate plan: $e')));
    }
  }

  Widget _buildDaySelector() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final isSelected = _selectedDay == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedDay = index),
            child: Container(
              width: 50,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.green : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSelected ? Colors.green : Colors.grey.shade300),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_days[index], style: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade600, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  CircleAvatar(
                    radius: 4,
                    backgroundColor: isSelected ? Colors.white : Colors.transparent,
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDaySlots(MealPlan plan) {
    final slots = plan.slots.where((s) => s.dayOfWeek == _selectedDay).toList();
    slots.sort((a, b) => _mealTypeOrder(a.mealType).compareTo(_mealTypeOrder(b.mealType)));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        return _buildSlotCard(plan.id, slot);
      },
    );
  }

  int _mealTypeOrder(String type) {
    switch (type) {
      case 'breakfast': return 0;
      case 'lunch': return 1;
      case 'dinner': return 2;
      case 'snack': return 3;
      default: return 4;
    }
  }

  Widget _buildSlotCard(String planId, MealSlot slot) {
    final hasRecipe = slot.recipe != null;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  slot.mealType.toUpperCase(),
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700, fontSize: 12),
                ),
                if (slot.isFlex)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: Colors.purple.shade100, borderRadius: BorderRadius.circular(12)),
                    child: Text('FLEX: ${slot.flexType?.toUpperCase()}', style: TextStyle(color: Colors.purple.shade700, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(hasRecipe ? LucideIcons.utensils : LucideIcons.coffee, color: Colors.grey.shade400),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasRecipe ? slot.recipe!.name : (slot.isFlex ? 'Rest day meal' : 'No recipe selected'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      if (hasRecipe) ...[
                        Row(
                          children: [
                            Icon(LucideIcons.clock, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text('${slot.recipe!.totalTimeMin}m', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                            const SizedBox(width: 12),
                            Icon(LucideIcons.flame, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(slot.recipe!.difficulty, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(LucideIcons.refreshCw, size: 16),
                label: const Text('Swap'),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(LucideIcons.coffee, size: 16),
                label: const Text('Flex'),
              ),
              if (!slot.isCompleted)
                TextButton.icon(
                  onPressed: () async {
                    await ref.read(mealPlanRepositoryProvider).completeSlot(planId, slot.id);
                    ref.invalidate(currentMealPlanProvider);
                  },
                  icon: const Icon(LucideIcons.checkCircle, size: 16, color: Colors.green),
                  label: const Text('Done', style: TextStyle(color: Colors.green)),
                )
              else
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    children: [
                      Icon(LucideIcons.checkCircle2, size: 16, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Completed', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }
}
