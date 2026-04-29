import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../repositories/meal_plan_repository.dart';
import '../models/meal_plan.dart';
import '../../../shared/theme/shadcn_theme.dart';

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
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(color: AppTheme.sage, strokeWidth: 2.5),
          ),
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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.menu, color: AppTheme.darkGreen),
          onPressed: () {},
        ),
        title: Text(
          'Meals',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkGreen,
          ),
        ),
        centerTitle: true,
      ),
      body: planAsync.when(
        data: (plan) {
          if (plan == null) return _buildEmptyState();
          return Column(
            children: [
              _buildDaySelector(),
              const Divider(height: 1, color: AppTheme.divider),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: KeyedSubtree(
                    key: ValueKey(_selectedDay),
                    child: _buildDayContent(plan),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.sage, strokeWidth: 2.5),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.alertCircle, size: 48, color: AppTheme.textCaption),
              const SizedBox(height: 12),
              Text(
                'Something went wrong',
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.darkGreen),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => ref.invalidate(currentMealPlanProvider),
                child: Text('Retry', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.sage)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.calendarDays, size: 48, color: AppTheme.textCaption),
            const SizedBox(height: 12),
            Text(
              'Your week is empty',
              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.darkGreen),
            ),
            const SizedBox(height: 8),
            Text(
              'Generate a new meal plan with AI or add it manually',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted, height: 1.5),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _generatePlan,
              icon: const Icon(LucideIcons.wand2, size: 16),
              label: Text('Generate with AI', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySelector() {
    return Container(
      color: AppTheme.background,
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 7,
        itemBuilder: (context, index) {
          final isSelected = _selectedDay == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedDay = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 24),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? AppTheme.sage : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                _days[index],
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  color: isSelected ? AppTheme.sage : AppTheme.textCaption,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDayContent(MealPlan plan) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: _mealPeriods.map((period) {
        final slot = plan.slots.firstWhere(
          (s) => s.dayOfWeek == _selectedDay && s.mealType == period,
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
  }

  Widget _buildMealPeriodSection(String period, MealSlot slot) {
    final periodLabel = period[0].toUpperCase() + period.substring(1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          periodLabel,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.darkGreen,
          ),
        ),
        const SizedBox(height: 10),
        slot.recipe != null ? _buildRecipeRow(slot) : _buildEmptySlot(),
        const SizedBox(height: 4),
        const Divider(color: AppTheme.divider),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRecipeRow(MealSlot slot) {
    return _PressableRow(
      onTap: () => context.push('/recipes/${slot.recipe!.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0E4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(LucideIcons.utensils, size: 24, color: AppTheme.sage.withValues(alpha: 0.6)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slot.recipe!.name,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.darkGreen,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(LucideIcons.clock, size: 13, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        '${slot.recipe!.totalTimeMin} mins',
                        style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted),
                      ),
                      const SizedBox(width: 10),
                      const Icon(LucideIcons.star, size: 13, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Text('4.0', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.gripVertical, size: 18, color: AppTheme.textCaption),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySlot() {
    return GestureDetector(
      onTap: () => context.go('/recipes'),
      child: DottedBorderBox(
        child: Center(
          child: Text(
            '+ Add Meal',
            style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textCaption),
          ),
        ),
      ),
    );
  }
}

class _PressableRow extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _PressableRow({required this.child, required this.onTap});

  @override
  State<_PressableRow> createState() => _PressableRowState();
}

class _PressableRowState extends State<_PressableRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
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



