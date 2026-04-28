import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../repositories/recipe_repository.dart';
import '../models/recipe.dart';

final recipeDetailProvider = FutureProvider.family<Recipe, String>((ref, id) {
  return ref.watch(recipeRepositoryProvider).getRecipe(id);
});

class RecipeDetailScreen extends ConsumerWidget {
  final String recipeId;

  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipeAsync = ref.watch(recipeDetailProvider(recipeId));

    return Scaffold(
      body: recipeAsync.when(
        data: (recipe) => CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 250.0,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(recipe.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black, blurRadius: 4)])),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(color: Colors.grey.shade300),
                    const Center(child: Icon(LucideIcons.image, size: 64, color: Colors.grey)),
                    // Add gradient for better text visibility
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(icon: const Icon(LucideIcons.heart), onPressed: () {}),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoItem(LucideIcons.clock, '${recipe.totalTimeMin}m'),
                        _buildInfoItem(LucideIcons.flame, recipe.difficulty),
                        _buildInfoItem(LucideIcons.tag, recipe.category ?? 'N/A'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    if (recipe.description != null) ...[
                      Text(recipe.description!, style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 24),
                    ],

                    Text('Ingredients', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    if (recipe.ingredients != null && recipe.ingredients!.isNotEmpty)
                      ...recipe.ingredients!.map((i) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            const Icon(Icons.circle, size: 8, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(child: Text(i, style: const TextStyle(fontSize: 16))),
                          ],
                        ),
                      )).toList()
                    else
                      const Text('No ingredients listed.', style: TextStyle(fontStyle: FontStyle.italic)),

                    const SizedBox(height: 24),
                    Text('Instructions', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    if (recipe.instructions != null && recipe.instructions!.isNotEmpty)
                      ...recipe.instructions!.asMap().entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.green.shade100,
                              child: Text('${e.key + 1}', style: TextStyle(color: Colors.green.shade800, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(e.value, style: const TextStyle(fontSize: 16, height: 1.5))),
                          ],
                        ),
                      )).toList()
                    else
                      const Text('No instructions listed.', style: TextStyle(fontStyle: FontStyle.italic)),
                      
                    const SizedBox(height: 80), // Padding for FAB
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading recipe: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(LucideIcons.chefHat, color: Colors.white),
        label: const Text('Cook Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.green.shade700, size: 28),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
