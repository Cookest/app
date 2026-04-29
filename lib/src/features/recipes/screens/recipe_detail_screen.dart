import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../repositories/recipe_repository.dart';
import '../models/recipe.dart';
import '../../../shared/theme/shadcn_theme.dart';

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

  void _showCookNowSheet(BuildContext context, Recipe recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
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
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Step 1',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.sage,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                recipe.instructions != null && recipe.instructions!.isNotEmpty
                    ? recipe.instructions!.first
                    : 'No instructions available.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppTheme.darkGreen,
                  height: 1.7,
                ),
              ),
              const Spacer(),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming soon')),
                    );
                  },
                  child: Text(
                    'Start Step-by-Step',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: AppTheme.sage,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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

    return RepaintBoundary(
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: recipeAsync.when(
          data: (recipe) => _buildContent(context, recipe),
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
                  onPressed: () => ref.invalidate(recipeDetailProvider(widget.recipeId)),
                  child: Text('Retry', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.sage)),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: recipeAsync.hasValue
            ? FloatingActionButton.extended(
                onPressed: () => _showCookNowSheet(context, recipeAsync.value!),
                backgroundColor: AppTheme.sage,
                icon: const Icon(LucideIcons.chefHat, color: Colors.white),
                label: Text(
                  'Cook Now',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildContent(BuildContext context, Recipe recipe) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 260.0,
          pinned: true,
          backgroundColor: AppTheme.darkGreen,
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  LucideIcons.heart,
                  key: ValueKey(_isFavorite),
                  color: _isFavorite ? const Color(0xFFEF4444) : Colors.white,
                  size: 22,
                ),
              ),
              onPressed: () => setState(() => _isFavorite = !_isFavorite),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(left: 56, right: 56, bottom: 16),
            title: Text(
              recipe.name,
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  color: const Color(0xFFE8F0E4),
                  child: const Center(
                    child: Icon(LucideIcons.utensils, size: 64, color: Color(0x407A9A65)),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.65)],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildInfoPill(LucideIcons.clock, '${recipe.totalTimeMin} min'),
                    const SizedBox(width: 8),
                    _buildInfoPill(LucideIcons.flame, recipe.difficulty),
                    if (recipe.category != null) ...[
                      const SizedBox(width: 8),
                      _buildInfoPill(LucideIcons.tag, recipe.category!),
                    ],
                  ],
                ),
                const SizedBox(height: 20),
                if (recipe.description != null) ...[
                  Text(
                    recipe.description!,
                    style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textMuted, height: 1.6),
                  ),
                  const SizedBox(height: 24),
                ],
                Text(
                  'Ingredients',
                  style: GoogleFonts.playfairDisplay(fontSize: 18, color: AppTheme.darkGreen),
                ),
                const SizedBox(height: 12),
                if (recipe.ingredients != null && recipe.ingredients!.isNotEmpty)
                  ...recipe.ingredients!.map(_buildIngredientRow)
                else
                  Text(
                    'No ingredients listed.',
                    style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted, fontStyle: FontStyle.italic),
                  ),
                const SizedBox(height: 24),
                Text(
                  'Instructions',
                  style: GoogleFonts.playfairDisplay(fontSize: 18, color: AppTheme.darkGreen),
                ),
                const SizedBox(height: 12),
                if (recipe.instructions != null && recipe.instructions!.isNotEmpty)
                  ...recipe.instructions!.asMap().entries.map((e) => _buildInstructionRow(e.key + 1, e.value))
                else
                  Text(
                    'No instructions listed.',
                    style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted, fontStyle: FontStyle.italic),
                  ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.sage.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppTheme.sage),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.sage, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientRow(String ingredient) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(color: AppTheme.sage, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              ingredient,
              style: GoogleFonts.inter(fontSize: 14, color: AppTheme.darkGreen, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionRow(int number, String instruction) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(color: AppTheme.sage, shape: BoxShape.circle),
            child: Center(
              child: Text(
                '$number',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                instruction,
                style: GoogleFonts.inter(fontSize: 16, color: AppTheme.darkGreen, height: 1.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
