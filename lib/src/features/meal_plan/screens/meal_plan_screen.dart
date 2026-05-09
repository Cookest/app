import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cookest_ui/cookest_ui.dart';
import '../repositories/meal_plan_repository.dart';
import '../models/meal_plan.dart';

class MealPlanScreen extends ConsumerStatefulWidget {
  const MealPlanScreen({super.key});

  @override
  ConsumerState<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends ConsumerState<MealPlanScreen> {
  int _selectedDay = DateTime.now().weekday - 1;
  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final List<String> _mealPeriods = ['breakfast', 'lunch', 'dinner'];

  Future<void> _generatePlan() async {
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
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Done!')),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate plan: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final planAsync = ref.watch(currentMealPlanProvider);

    return Scaffold(
      backgroundColor: CookestTokens.colorBackgroundLight,
      appBar: AppBar(
        backgroundColor: CookestTokens.colorBackgroundLight,
        elevation: 0,
        title: Text(
          'Meal Plan',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: CookestTokens.colorHeadingLight,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CkButton(
              variant: CkButtonVariant.ghost,
              size: CkButtonSize.sm,
              iconLeft: const Icon(LucideIcons.sparkles, size: 16),
              onPressed: _generatePlan,
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
              initialTab: '0',
              items: List.generate(
                _days.length,
                (i) => CkTabItem(id: i.toString(), label: _days[i]),
              ),
              onChanged: (id) =>
                  setState(() => _selectedDay = int.parse(id)),
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
                              color: CookestTokens.colorMutedLight),
                          const SizedBox(height: 12),
                          Text(
                            'Your week is empty',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                    color: CookestTokens.colorHeadingLight),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Generate a meal plan with AI or add meals manually.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: CookestTokens.colorMutedLight),
                          ),
                          const SizedBox(height: 24),
                          CkButton(
                            iconLeft: const Icon(LucideIcons.sparkles,
                                size: 16),
                            onPressed: _generatePlan,
                            child: const Text('Generate with AI'),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView(
                    children: _mealPeriods.map((period) {
                      final slot = plan.slots.firstWhere(
                        (s) =>
                            s.dayOfWeek == _selectedDay &&
                            s.mealType == period,
                        orElse: () => MealSlot(
                          id: '${_selectedDay}_$period',
                          dayOfWeek: _selectedDay,
                          mealType: period,
                          servings: 2,
                          isFlex: false,
                          isCompleted: false,
                        ),
                      );
                      return _buildMealPeriodSection(period, slot);
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

  Widget _buildMealPeriodSection(String period, MealSlot slot) {
    final periodLabel = period[0].toUpperCase() + period.substring(1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          periodLabel,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: CookestTokens.colorHeadingLight,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 10),
        slot.recipe != null
            ? CkCard(
                variant: CkCardVariant.interactive,
                padding: CkCardPadding.md,
                onTap: () {},
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: CookestTokens.colorSurfaceLight,
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
                                  color: CookestTokens.colorHeadingLight,
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
                                  color: CookestTokens.colorMutedLight),
                              const SizedBox(width: 4),
                              Text(
                                '${slot.recipe!.totalTimeMin} mins',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: CookestTokens.colorMutedLight),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : DottedBorderBox(
                child: Center(
                  child: Text(
                    '+ Add Meal',
                    style: TextStyle(
                        fontSize: 14, color: CookestTokens.colorMutedLight),
                  ),
                ),
              ),
        const SizedBox(height: 4),
        Divider(color: CookestTokens.colorBorderLight),
        const SizedBox(height: 16),
      ],
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
