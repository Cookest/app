import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cookest_ui/cookest_ui.dart';
import 'package:cookest/src/core/theme/app_colors.dart';
import '../repositories/recipe_repository.dart';
import '../models/recipe.dart';

final recipeDetailProvider = FutureProvider.family<Recipe, String>((ref, id) {
  return ref.watch(recipeRepositoryProvider).getRecipe(id);
});

class RecipeDetailScreen extends ConsumerStatefulWidget {
  final String recipeId;
  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  bool _isFavorite = false;

  void _showCookSheet(BuildContext context, Recipe recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.appSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(ctx).size.height * 0.5,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.appBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Let\'s cook!',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: context.appHeading,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                recipe.name,
                style: Theme.of(ctx).textTheme.bodyLarge?.copyWith(
                      color: context.appMuted,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipeAsync = ref.watch(recipeDetailProvider(widget.recipeId));

    return Scaffold(
      backgroundColor: context.appBackground,
      appBar: AppBar(
        backgroundColor: context.appBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: recipeAsync.maybeWhen(
          data: (recipe) => Text(
            recipe.name,
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.appHeading,
            ),
          ),
          orElse: () => const SizedBox.shrink(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? LucideIcons.heart : LucideIcons.heart,
              color: _isFavorite
                  ? CookestTokens.colorStatusError
                  : context.appMuted,
            ),
            onPressed: () => setState(() => _isFavorite = !_isFavorite),
          ),
        ],
      ),
      body: recipeAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: CkSkeletonCard(),
        ),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: CkAlert(
            variant: CkAlertVariant.error,
            child: Text('Failed to load recipe: $e'),
          ),
        ),
        data: (recipe) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (recipe.category != null)
                          CkBadge(
                            variant: CkBadgeVariant.info,
                            size: CkBadgeSize.md,
                            child: Text(recipe.category!),
                          ),
                        const SizedBox(width: 8),
                        if (recipe.cuisine != null)
                          CkBadge(
                            variant: CkBadgeVariant.standard,
                            size: CkBadgeSize.md,
                            child: Text(recipe.cuisine!),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ingredients',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: context.appHeading,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    CkCard(
                      variant: CkCardVariant.standard,
                      padding: CkCardPadding.md,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: (recipe.ingredients ?? [])
                            .map(
                              (ing) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('• ',
                                        style: TextStyle(fontSize: 14)),
                                    Expanded(
                                      child: Text(
                                        ing,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Instructions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: context.appHeading,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ...(recipe.instructions ?? []).asMap().entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: CookestTokens.colorPrimaryDEFAULT,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${entry.key + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    entry.value,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    const SizedBox(height: 24),
                    CkButton(
                      fullWidth: true,
                      size: CkButtonSize.lg,
                      iconLeft: const Icon(LucideIcons.chefHat),
                      onPressed: () => _showCookSheet(context, recipe),
                      child: const Text('Start Cooking'),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
