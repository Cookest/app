import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cookest_ui/cookest_ui.dart';
import 'package:cookest/src/core/theme/app_colors.dart';
import '../repositories/recipe_repository.dart';
import '../models/recipe.dart';

final recipeSearchProvider = StateProvider<String>((ref) => '');
final recipeMatchInventoryProvider = StateProvider<bool>((ref) => false);
final recipeCategoryProvider = StateProvider<String>((ref) => 'All');

final recipesListProvider = FutureProvider<List<Recipe>>((ref) {
  final query = ref.watch(recipeSearchProvider);
  final matchInventory = ref.watch(recipeMatchInventoryProvider);
  final category = ref.watch(recipeCategoryProvider);
  return ref.watch(recipeRepositoryProvider).getRecipes(
    q: query.isEmpty ? null : query,
    matchInventory: matchInventory,
    category: category == 'All' ? null : category,
  );
});

class RecipesScreen extends ConsumerStatefulWidget {
  const RecipesScreen({super.key});

  @override
  ConsumerState<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends ConsumerState<RecipesScreen> {
  static const _categories = ['All', 'Breakfast', 'Lunch', 'Dinner', 'Snack'];
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(recipeSearchProvider.notifier).state = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final recipesAsync = ref.watch(recipesListProvider);
    final selectedCategory = ref.watch(recipeCategoryProvider);
    final matchInventory = ref.watch(recipeMatchInventoryProvider);

    return Scaffold(
      backgroundColor: context.appBackground,
      appBar: AppBar(
        backgroundColor: context.appBackground,
        elevation: 0,
        title: Text(
          'Recipes',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: context.appHeading,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CkButton(
              variant: CkButtonVariant.ghost,
              size: CkButtonSize.sm,
              iconLeft: const Icon(LucideIcons.plus, size: 16),
              onPressed: () => context.push('/recipes/create'),
              child: const Text('Add'),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        heroTag: 'pantry-filter',
        onPressed: () => _showPantryFilterModal(context, ref),
        tooltip: matchInventory ? 'Showing pantry matches' : 'Filter by pantry',
        child: Icon(
          LucideIcons.filter,
          color: matchInventory ? Colors.white : null,
        ),
        backgroundColor: matchInventory
            ? CookestTokens.colorPrimaryDEFAULT
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            CkInput(
              placeholder: 'Search recipes...',
              iconLeft: const Icon(LucideIcons.search, size: 16),
              fullWidth: true,
              onChanged: _onSearchChanged,
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        ref.read(recipeCategoryProvider.notifier).state = cat;
                      },
                      child: CkBadge(
                        variant: isSelected
                            ? CkBadgeVariant.success
                            : CkBadgeVariant.standard,
                        size: CkBadgeSize.md,
                        child: Text(cat),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            if (matchInventory)
              CkBadge(
                variant: CkBadgeVariant.success,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.checkCircle, size: 14),
                    const SizedBox(width: 6),
                    const Text('Showing pantry matches'),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () {
                        ref.read(recipeMatchInventoryProvider.notifier).state = false;
                      },
                      child: const Icon(LucideIcons.x, size: 14),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: recipesAsync.when(
                loading: () => ListView(
                  children: const [
                    CkSkeletonCard(),
                    SizedBox(height: 12),
                    CkSkeletonCard(),
                    SizedBox(height: 12),
                    CkSkeletonCard(),
                  ],
                ),
                error: (e, _) => CkAlert(
                  variant: CkAlertVariant.error,
                  child: Text('Failed to load recipes: $e'),
                ),
                data: (recipes) => ListView.builder(
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CkCard(
                        variant: CkCardVariant.interactive,
                        padding: CkCardPadding.md,
                        onTap: () => context.push('/recipes/${recipe.id}'),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: recipe.primaryImageUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: recipe.primaryImageUrl!,
                                      width: 72,
                                      height: 72,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => Container(
                                        width: 72,
                                        height: 72,
                                        color: context.appSurface,
                                        child: Icon(LucideIcons.utensils,
                                            size: 24, color: context.appMuted),
                                      ),
                                      errorWidget: (_, __, ___) => Container(
                                        width: 72,
                                        height: 72,
                                        color: context.appSurface,
                                        child: Icon(LucideIcons.utensils,
                                            size: 24, color: context.appMuted),
                                      ),
                                    )
                                  : Container(
                                      width: 72,
                                      height: 72,
                                      color: context.appSurface,
                                      child: Icon(LucideIcons.utensils,
                                          size: 24, color: context.appMuted),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    recipe.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          color: context.appHeading,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      CkBadge(
                                        variant: CkBadgeVariant.info,
                                        size: CkBadgeSize.sm,
                                        child: Text(recipe.category ?? 'Other'),
                                      ),
                                      const SizedBox(width: 8),
                                      CkBadge(
                                        variant: CkBadgeVariant.standard,
                                        size: CkBadgeSize.sm,
                                        child: Text(recipe.totalTimeMin != null ? '\${recipe.totalTimeMin} min' : recipe.difficulty ?? 'easy'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Icon(LucideIcons.chevronRight, size: 16),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPantryFilterModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Recipes',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Only show recipes I can make',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  CkToggle(
                    value: ref.watch(recipeMatchInventoryProvider),
                    onChanged: (val) {
                      ref.read(recipeMatchInventoryProvider.notifier).state = val;
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Shows only recipes where you have most ingredients in pantry',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: context.appMuted),
              ),
              const SizedBox(height: 16),
              CkButton(
                variant: CkButtonVariant.ghost,
                fullWidth: true,
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
