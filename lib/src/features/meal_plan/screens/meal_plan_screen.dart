import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cookest_ui/cookest_ui.dart';
import 'package:cookest/src/core/theme/app_colors.dart';
import '../repositories/meal_plan_repository.dart';
import '../models/meal_plan.dart';
import '../../shopping_list/repositories/shopping_repository.dart';

// ─ State providers (memoized) ────────────────────────────────────────────────
final selectedDayProvider = StateProvider<int>((ref) => DateTime.now().weekday - 1);
final isGeneratingPlanProvider = StateProvider<bool>((ref) => false);

// ─ Computed provider for meal slots (cached) ────────────────────────────────
final mealSlotProvider = Provider.family<MealSlot?, (MealPlan?, int, String)>(
  (ref, args) {
    final (plan, dayOfWeek, mealType) = args;
    if (plan == null) return null;
    
    return plan.slots.firstWhere(
      (s) => s.dayOfWeek == dayOfWeek && s.mealType == mealType,
      orElse: () => MealSlot(
        id: '${dayOfWeek}_$mealType',
        dayOfWeek: dayOfWeek,
        mealType: mealType,
        servings: 2,
        isFlex: false,
        isCompleted: false,
      ),
    );
  },
);

class MealPlanScreen extends ConsumerWidget {
  const MealPlanScreen({super.key});

  static const List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const List<String> _mealPeriods = ['breakfast', 'lunch', 'dinner'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(currentMealPlanProvider);
    final selectedDay = ref.watch(selectedDayProvider);
    final isGeneratingPlan = ref.watch(isGeneratingPlanProvider);

    return Scaffold(
      backgroundColor: context.appBackground,
      appBar: AppBar(
        backgroundColor: context.appBackground,
        elevation: 0,
        title: Text(
          'Meal Plan',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: context.appHeading,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: CkButton(
              variant: CkButtonVariant.ghost,
              size: CkButtonSize.sm,
              iconLeft: const Icon(LucideIcons.shoppingCart, size: 16),
              onPressed: () => _syncGroceries(context, ref),
              child: const Text('Sync'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CkButton(
              variant: CkButtonVariant.ghost,
              size: CkButtonSize.sm,
              iconLeft: const Icon(LucideIcons.sparkles, size: 16),
              loading: isGeneratingPlan,
              onPressed: isGeneratingPlan ? null : () => _generatePlan(context, ref),
              child: const Text('Generate'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            CkTabs(
              variant: CkTabsVariant.underline,
              fullWidth: true,
              initialTab: selectedDay.toString(),
              items: List.generate(
                _days.length,
                (i) => CkTabItem(id: i.toString(), label: _days[i]),
              ),
              onChanged: (id) {
                ref.read(selectedDayProvider.notifier).state = int.parse(id);
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: planAsync.when(
                loading: () => const Column(
                  children: [
                    CkSkeletonCard(),
                    SizedBox(height: 12),
                    CkSkeletonCard(),
                    SizedBox(height: 12),
                    CkSkeletonCard(),
                  ],
                ),
                error: (e, _) => CkAlert(
                  variant: CkAlertVariant.error,
                  child: Text('Failed to load meal plan: $e'),
                ),
                data: (plan) {
                  if (plan == null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.calendarDays,
                              size: 48,
                              color: context.appMuted),
                          const SizedBox(height: 12),
                          Text(
                            'Your week is empty',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                    color: context.appHeading),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Generate a meal plan with AI or add meals manually.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: context.appMuted),
                          ),
                          const SizedBox(height: 24),
                          CkButton(
                            iconLeft: const Icon(LucideIcons.sparkles,
                                size: 16),
                            loading: isGeneratingPlan,
                            onPressed: isGeneratingPlan
                                ? null
                                : () => _generatePlan(context, ref),
                            child: const Text('Generate with AI'),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView(
                    physics: const ClampingScrollPhysics(),
                    children: _mealPeriods.map((period) {
                      return _MealPeriodCard(
                        period: period,
                        plan: plan,
                        selectedDay: selectedDay,
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _generatePlan(BuildContext context, WidgetRef ref) async {
    ref.read(isGeneratingPlanProvider.notifier).state = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: CkCard(
          padding: CkCardPadding.lg,
          child: const CkSpinner(size: CkSpinnerSize.md),
        ),
      ),
    );

    try {
      await ref.read(mealPlanRepositoryProvider).generatePlan();
      ref.invalidate(currentMealPlanProvider);
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Done!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate plan: $e')),
        );
      }
    } finally {
      ref.read(isGeneratingPlanProvider.notifier).state = false;
    }
  }

  static Future<void> _syncGroceries(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(shoppingRepositoryProvider).syncFromPlan();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Groceries synced from meal plan.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sync groceries: $e')),
      );
    }
  }
}

// ─ Separated widget to prevent unnecessary rebuilds ─────────────────────────
class _MealPeriodCard extends ConsumerWidget {
  final String period;
  final MealPlan plan;
  final int selectedDay;

  const _MealPeriodCard({
    required this.period,
    required this.plan,
    required this.selectedDay,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slot = ref.watch(mealSlotProvider((plan, selectedDay, period)));
    if (slot == null) return const SizedBox.shrink();

    final periodLabel = period[0].toUpperCase() + period.substring(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          periodLabel,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: context.appHeading,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 10),
        slot.recipe != null
            ? _MealCardContent(slot: slot, plan: plan)
            : const _EmptyMealCard(),
        const SizedBox(height: 4),
        Divider(color: context.appBorder),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _MealCardContent extends ConsumerWidget {
  final MealSlot slot;
  final MealPlan plan;

  const _MealCardContent({
    required this.slot,
    required this.plan,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CkCard(
      variant: CkCardVariant.interactive,
      padding: CkCardPadding.md,
      onTap: slot.recipe != null
          ? () => context.push('/recipes/${slot.recipe!.id}')
          : null,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: context.appSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(LucideIcons.utensils,
                size: 20,
                color: CookestTokens.colorPrimaryDEFAULT),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slot.recipe!.name,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(
                        color: context.appHeading,
                        fontWeight: FontWeight.w500,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(LucideIcons.clock,
                        size: 13,
                        color: context.appMuted),
                    const SizedBox(width: 4),
                    Text(
                      '${slot.recipe!.totalTimeMin} mins',
                      style: TextStyle(
                          fontSize: 13,
                          color: context.appMuted),
                    ),
                    const SizedBox(width: 8),
                    if (slot.recipe!.cuisine != null)
                      Expanded(
                        child: Text(
                          slot.recipe!.cuisine!,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.appMuted,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (slot.isCompleted)
                      const CkBadge(
                        variant: CkBadgeVariant.success,
                        child: Text('Completed'),
                      ),
                    if (slot.isFlex)
                      CkBadge(
                        variant: CkBadgeVariant.warning,
                        child: Text(slot.flexType ?? 'Flex'),
                      ),
                    CkButton(
                      size: CkButtonSize.sm,
                      variant: CkButtonVariant.secondary,
                      iconLeft: const Icon(LucideIcons.check, size: 14),
                      onPressed: slot.isCompleted
                          ? null
                          : () => _markComplete(context, ref),
                      child: const Text('Complete'),
                    ),
                    CkButton(
                      size: CkButtonSize.sm,
                      variant: CkButtonVariant.ghost,
                      iconLeft: const Icon(LucideIcons.refreshCcw, size: 14),
                      onPressed: slot.isFlex
                          ? null
                          : () => _setFlex(context, ref),
                      child: const Text('Flex'),
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

  void _markComplete(BuildContext context, WidgetRef ref) async {
    final planId = int.tryParse(plan.id);
    final slotId = int.tryParse(slot.id);
    if (planId == null || slotId == null) return;

    try {
      await ref.read(mealPlanRepositoryProvider).completeSlot(
            planId.toString(),
            slotId.toString(),
          );
      ref.invalidate(currentMealPlanProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meal marked as completed.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    }
  }

  void _setFlex(BuildContext context, WidgetRef ref) async {
    final planId = int.tryParse(plan.id);
    final slotId = int.tryParse(slot.id);
    if (planId == null || slotId == null) return;

    try {
      await ref.read(mealPlanRepositoryProvider).setFlex(
            planId.toString(),
            slotId.toString(),
            'leftovers',
          );
      ref.invalidate(currentMealPlanProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Marked as flex day.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    }
  }
}

class _EmptyMealCard extends StatelessWidget {
  const _EmptyMealCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/recipes'),
      child: DottedBorderBox(
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.plus, size: 18),
              const SizedBox(width: 6),
              Text(
                'Add Meal',
                style: TextStyle(
                    fontSize: 14, color: context.appMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DottedBorderBox extends StatelessWidget {
  final Widget child;
  const DottedBorderBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(),
      child: Container(
        height: 56,
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    final borderRadius = BorderRadius.circular(10);
    final rrect = borderRadius.toRRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
