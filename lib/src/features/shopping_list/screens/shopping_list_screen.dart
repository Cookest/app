import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../repositories/shopping_repository.dart';
import '../models/shopping_item.dart';
import '../../../shared/theme/shadcn_theme.dart';

class ShoppingListScreen extends ConsumerStatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  ConsumerState<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends ConsumerState<ShoppingListScreen> {
  final _addController = TextEditingController();
  final Set<String> _expandedCategories = {'all'};

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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error syncing: $e')));
    }
  }

  Future<void> _addItem() async {
    final text = _addController.text.trim();
    if (text.isEmpty) return;
    try {
      await ref.read(shoppingRepositoryProvider).addItem(text, 1, 'pcs');
      _addController.clear();
      ref.invalidate(shoppingListProvider);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error adding: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(shoppingListProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: Text(
          'Groceries List',
          style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.darkGreen),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.arrowUpDown, color: AppTheme.darkGreen, size: 20),
            onPressed: _sync,
            tooltip: 'Sync from Meal Plan',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _addController,
                    decoration: InputDecoration(
                      hintText: 'Add an item...',
                      prefixIcon: const Icon(LucideIcons.plus, size: 18, color: AppTheme.textCaption),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.border)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.border)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.sage, width: 1.5)),
                      filled: true,
                      fillColor: AppTheme.surface,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      hintStyle: GoogleFonts.inter(fontSize: 14, color: AppTheme.textCaption),
                    ),
                    onSubmitted: (_) => _addItem(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.sage,
                    foregroundColor: AppTheme.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    elevation: 0,
                  ),
                  child: Text('Add', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
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
                        Icon(LucideIcons.shoppingCart, size: 48, color: AppTheme.textCaption),
                        const SizedBox(height: 12),
                        Text(
                          'Your shopping list is empty',
                          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.darkGreen),
                        ),
                        const SizedBox(height: 6),
                        TextButton(
                          onPressed: _sync,
                          child: Text('Sync from Meal Plan', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.sage)),
                        ),
                      ],
                    ),
                  );
                }

                final sorted = [...items]..sort((a, b) {
                  if (a.isChecked == b.isChecked) return 0;
                  return a.isChecked ? 1 : -1;
                });

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildCategorySection('Items', sorted),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.sage)),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String category, List<ShoppingItem> items) {
    final isExpanded = _expandedCategories.contains(category);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() {
            if (isExpanded) {
              _expandedCategories.remove(category);
            } else {
              _expandedCategories.add(category);
            }
          }),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Text(
                  category,
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.darkGreen),
                ),
                const SizedBox(width: 8),
                Text(
                  '${items.length}',
                  style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textCaption),
                ),
                const Spacer(),
                Icon(isExpanded ? LucideIcons.chevronDown : LucideIcons.chevronRight, size: 18, color: AppTheme.textMuted),
              ],
            ),
          ),
        ),
        if (isExpanded) ...items.map((item) => _buildItemRow(item)),
        const Divider(color: AppTheme.divider),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildItemRow(ShoppingItem item) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: AppTheme.destructive, borderRadius: BorderRadius.circular(10)),
        child: const Icon(LucideIcons.trash2, color: Colors.white, size: 18),
      ),
      onDismissed: (_) async {
        await ref.read(shoppingRepositoryProvider).deleteItem(item.id);
        ref.invalidate(shoppingListProvider);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            GestureDetector(
              onTap: () async {
                try {
                  await ref.read(shoppingRepositoryProvider).toggleCheck(item.id, !item.isChecked);
                  ref.invalidate(shoppingListProvider);
                } catch (_) {}
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: item.isChecked ? AppTheme.sage : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: item.isChecked ? null : Border.all(color: AppTheme.sage, width: 1.5),
                ),
                child: item.isChecked
                    ? const Icon(LucideIcons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.name,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: item.isChecked ? AppTheme.textCaption : AppTheme.darkGreen,
                  decoration: item.isChecked ? TextDecoration.lineThrough : null,
                  decorationColor: AppTheme.textCaption,
                ),
              ),
            ),
            Text(
              '${item.quantity} ${item.unit}',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: item.isChecked ? AppTheme.textCaption : AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

