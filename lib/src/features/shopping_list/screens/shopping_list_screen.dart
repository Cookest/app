import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../repositories/shopping_repository.dart';
import '../models/shopping_item.dart';

class ShoppingListScreen extends ConsumerStatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  ConsumerState<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends ConsumerState<ShoppingListScreen> {
  final _addController = TextEditingController();

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  Future<void> _sync() async {
    try {
      await ref.read(shoppingRepositoryProvider).syncFromPlan();
      ref.invalidate(shoppingListProvider);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error syncing: $e')));
    }
  }

  Future<void> _addItem() async {
    final text = _addController.text.trim();
    if (text.isEmpty) return;

    try {
      await ref.read(shoppingRepositoryProvider).addItem(text, 1, 'pcs'); // Simplified for quick add
      _addController.clear();
      ref.invalidate(shoppingListProvider);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error adding: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(shoppingListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw),
            tooltip: 'Sync from Meal Plan',
            onPressed: _sync,
          ),
          IconButton(
            icon: const Icon(LucideIcons.zap),
            tooltip: 'Optimize Prices (Pro)',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Price Optimizer is a Pro feature!')));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _addController,
                    decoration: InputDecoration(
                      hintText: 'Add an item...',
                      prefixIcon: const Icon(LucideIcons.plus),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onSubmitted: (_) => _addItem(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: listAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.shoppingBag, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        const Text('Your shopping list is empty.'),
                        TextButton(onPressed: _sync, child: const Text('Sync from Meal Plan')),
                      ],
                    ),
                  );
                }

                // Sort: unchecked first, then checked
                items.sort((a, b) {
                  if (a.isChecked == b.isChecked) return 0;
                  return a.isChecked ? 1 : -1;
                });

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Dismissible(
                      key: Key(item.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child: const Icon(LucideIcons.trash2, color: Colors.white),
                      ),
                      onDismissed: (_) async {
                        await ref.read(shoppingRepositoryProvider).deleteItem(item.id);
                        ref.invalidate(shoppingListProvider);
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        child: CheckboxListTile(
                          value: item.isChecked,
                          title: Text(
                            item.name,
                            style: TextStyle(
                              decoration: item.isChecked ? TextDecoration.lineThrough : null,
                              color: item.isChecked ? Colors.grey : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text('${item.quantity} ${item.unit}'),
                          activeColor: Colors.green,
                          onChanged: (val) async {
                            if (val == null) return;
                            try {
                              await ref.read(shoppingRepositoryProvider).toggleCheck(item.id, val);
                              ref.invalidate(shoppingListProvider);
                            } catch (_) {}
                          },
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
