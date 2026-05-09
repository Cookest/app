import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cookest_ui/cookest_ui.dart';
import 'package:cookest/src/core/theme/app_colors.dart';
import '../../meal_plan/repositories/meal_plan_repository.dart';
import '../../pantry/repositories/inventory_repository.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealPlanAsync = ref.watch(currentMealPlanProvider);
    final expiringCountAsync = ref.watch(expiringCountProvider);

    return Scaffold(
      backgroundColor: context.appBackground,
      appBar: AppBar(
        backgroundColor: context.appBackground,
        elevation: 0,
        title: Text(
          'Good morning 👋',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: context.appHeading,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: CkAvatar(alt: 'User', size: CkAvatarSize.sm),
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.messageCircle),
            onPressed: () => context.push('/chat'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            expiringCountAsync.maybeWhen(
              data: (count) => count > 0
                  ? Column(
                      children: [
                        CkAlert(
                          variant: CkAlertVariant.warning,
                          title: 'Pantry alert',
                          dismissible: false,
                          icon: const Icon(LucideIcons.alertTriangle, size: 16),
                          child: Text('$count item(s) expiring soon'),
                        ),
                        const SizedBox(height: 16),
                      ],
                    )
                  : const SizedBox.shrink(),
              orElse: () => const SizedBox.shrink(),
            ),
            Text(
              "Today's meal",
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.appHeading,
              ),
            ),
            const SizedBox(height: 12),
            mealPlanAsync.when(
              loading: () => const CkSkeletonCard(),
              error: (e, _) => CkAlert(
                variant: CkAlertVariant.error,
                child: Text('Failed to load meal plan: $e'),
              ),
              data: (mealPlan) {
                if (mealPlan == null) {
                  return CkCard(
                    variant: CkCardVariant.interactive,
                    padding: CkCardPadding.md,
                    child: const Center(child: Text('No meal planned')),
                  );
                }
                final dayOfWeek = DateTime.now().weekday - 1;
                final dinner = mealPlan.slots
                    .where((s) =>
                        s.dayOfWeek == dayOfWeek && s.mealType == 'dinner')
                    .firstOrNull;
                return CkCard(
                  variant: CkCardVariant.interactive,
                  padding: CkCardPadding.md,
                  onTap: dinner?.recipe != null
                      ? () => context.push('/recipes/${dinner!.recipe!.id}')
                      : null,
                  child: dinner?.recipe != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(LucideIcons.utensils, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  'Dinner',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: context.appMuted,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              dinner!.recipe!.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: context.appHeading,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        )
                      : const Center(
                          child: Text('No meal planned for tonight')),
                );
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text(
                  'Quick actions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: context.appHeading,
                      ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.push('/recipes'),
                  child: const Text('View all'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CkCard(
                    variant: CkCardVariant.interactive,
                    padding: CkCardPadding.sm,
                    onTap: () => context.push('/recipes'),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.search, size: 24),
                        const SizedBox(height: 6),
                        Text(
                          'Find Recipe',
                          style: Theme.of(context).textTheme.labelMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CkCard(
                    variant: CkCardVariant.interactive,
                    padding: CkCardPadding.sm,
                    onTap: () => context.push('/meals'),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.calendar, size: 24),
                        const SizedBox(height: 6),
                        Text(
                          'Meal Plan',
                          style: Theme.of(context).textTheme.labelMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CkCard(
                    variant: CkCardVariant.interactive,
                    padding: CkCardPadding.sm,
                    onTap: () => context.push('/groceries'),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.shoppingCart, size: 24),
                        const SizedBox(height: 6),
                        Text(
                          'Groceries',
                          style: Theme.of(context).textTheme.labelMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
