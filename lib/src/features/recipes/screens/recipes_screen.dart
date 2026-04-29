import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../repositories/recipe_repository.dart';
import '../models/recipe.dart';
import '../../../shared/theme/shadcn_theme.dart';

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

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: Text(
          'Recipes',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkGreen,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.sliders, color: AppTheme.darkGreen),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search recipes',
                prefixIcon: const Icon(LucideIcons.search, size: 18, color: AppTheme.textCaption),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.sage, width: 1.5),
                ),
                filled: true,
                fillColor: AppTheme.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                hintStyle: GoogleFonts.inter(fontSize: 14, color: AppTheme.textCaption),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isActive = selectedCategory == cat;
                return GestureDetector(
                  onTap: () => ref.read(recipeCategoryProvider.notifier).state = cat,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? AppTheme.sage : AppTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: isActive ? null : Border.all(color: AppTheme.border),
                    ),
                    child: Text(
                      cat,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                        color: isActive ? AppTheme.surface : AppTheme.textMuted,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: recipesAsync.when(
              data: (recipes) {
                if (recipes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.chefHat, size: 48, color: AppTheme.textCaption),
                        const SizedBox(height: 12),
                        Text(
                          'No recipes found',
                          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.darkGreen),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Try a different search or category',
                          style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: recipes.length,
                  itemBuilder: (context, index) => RepaintBoundary(
                    child: _PressableRecipeCard(recipe: recipes[index]),
                  ),
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
                      onPressed: () => ref.invalidate(recipesListProvider),
                      child: Text('Retry', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.sage)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PressableRecipeCard extends StatefulWidget {
  final Recipe recipe;
  const _PressableRecipeCard({required this.recipe});

  @override
  State<_PressableRecipeCard> createState() => _PressableRecipeCardState();
}

class _PressableRecipeCardState extends State<_PressableRecipeCard> {
  bool _pressed = false;
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        context.push('/recipes/${widget.recipe.id}');
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [AppTheme.cardShadow],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    height: 160,
                    width: double.infinity,
                    color: const Color(0xFFE8F0E4),
                    child: Center(
                      child: Icon(LucideIcons.utensils, size: 40, color: AppTheme.sage.withValues(alpha: 0.4)),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () => setState(() => _isFavorite = !_isFavorite),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppTheme.surface.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            LucideIcons.heart,
                            key: ValueKey(_isFavorite),
                            size: 18,
                            color: _isFavorite ? const Color(0xFFEF4444) : AppTheme.textCaption,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.recipe.name,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 17,
                        fontWeight: FontWeight.normal,
                        color: AppTheme.darkGreen,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.recipe.category ?? 'Recipe',
                      style: GoogleFonts.inter(fontSize: 12, color: AppTheme.sage),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(LucideIcons.clock, size: 13, color: AppTheme.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.recipe.totalTimeMin} mins',
                          style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted),
                        ),
                        const SizedBox(width: 12),
                        const Icon(LucideIcons.star, size: 13, color: AppTheme.textMuted),
                        const SizedBox(width: 4),
                        Text('4.0', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted)),
                        const SizedBox(width: 12),
                        Text(
                          widget.recipe.difficulty,
                          style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
