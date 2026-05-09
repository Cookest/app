import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:cookest_ui/cookest_ui.dart';
import '../repositories/inventory_repository.dart';
import '../models/inventory_item.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showAddItemDialog() async {
    final nameController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    final unitController = TextEditingController(text: 'pcs');
    String location = 'pantry';
    DateTime? expiryDate;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: CookestTokens.colorSurfaceLight,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              'Add Item',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 20, color: CookestTokens.colorHeadingLight),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CkInput(
                    controller: nameController,
                    label: 'Item Name',
                    placeholder: 'e.g. Milk',
                    fullWidth: true,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CkInput(
                          controller: quantityController,
                          label: 'Quantity',
                          placeholder: '1',
                          keyboardType: TextInputType.number,
                          fullWidth: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CkInput(
                          controller: unitController,
                          label: 'Unit',
                          placeholder: 'pcs',
                          fullWidth: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CkSelect(
                    label: 'Location',
                    placeholder: 'Select location',
                    options: ['fridge', 'pantry', 'freezer']
                        .map((loc) => CkSelectOption(
                              value: loc,
                              label: loc[0].toUpperCase() + loc.substring(1),
                            ))
                        .toList(),
                    value: location,
                    onChanged: (v) => setDialogState(() => location = v),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      expiryDate == null
                          ? 'Set Expiry Date'
                          : 'Expires: ${DateFormat.yMd().format(expiryDate!)}',
                      style: TextStyle(
                          fontSize: 14,
                          color: CookestTokens.colorHeadingLight),
                    ),
                    trailing: Icon(LucideIcons.calendar,
                        color: CookestTokens.colorPrimaryDEFAULT),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate:
                            DateTime.now().add(const Duration(days: 7)),
                        firstDate: DateTime.now(),
                        lastDate:
                            DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setDialogState(() => expiryDate = date);
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel',
                    style: TextStyle(color: CookestTokens.colorMutedLight)),
              ),
              CkButton(
                onPressed: () async {
                  if (nameController.text.isEmpty) return;
                  await ref.read(inventoryRepositoryProvider).addItem({
                    'name': nameController.text,
                    'quantity':
                        double.tryParse(quantityController.text) ?? 1.0,
                    'unit': unitController.text,
                    'location': location,
                    if (expiryDate != null)
                      'expiry_date': expiryDate!.toIso8601String(),
                  });
                  ref.invalidate(inventoryListProvider);
                  ref.invalidate(expiringCountProvider);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inventoryAsync = ref.watch(inventoryListProvider);
    final expiringCountAsync = ref.watch(expiringCountProvider);

    return Scaffold(
      backgroundColor: CookestTokens.colorBackgroundLight,
      appBar: AppBar(
        backgroundColor: CookestTokens.colorBackgroundLight,
        elevation: 0,
        title: Text(
          'Pantry',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: CookestTokens.colorHeadingLight,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        backgroundColor: CookestTokens.colorPrimaryDEFAULT,
        foregroundColor: Colors.white,
        elevation: 2,
        child: const Icon(LucideIcons.plus),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 12),
            CkInput(
              controller: _searchController,
              placeholder: 'Search items...',
              iconLeft: const Icon(LucideIcons.search, size: 16),
              fullWidth: true,
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
            const SizedBox(height: 12),
            expiringCountAsync.maybeWhen(
              data: (count) => count > 0
                  ? Column(
                      children: [
                        CkAlert(
                          variant: CkAlertVariant.warning,
                          title: 'Expiring soon',
                          child: Text(
                              '$count item(s) expire within 3 days'),
                        ),
                        const SizedBox(height: 12),
                      ],
                    )
                  : const SizedBox.shrink(),
              orElse: () => const SizedBox.shrink(),
            ),
            Expanded(
              child: inventoryAsync.when(
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
                  child: Text('Failed to load inventory: $e'),
                ),
                data: (items) {
                  final filtered = _searchQuery.isEmpty
                      ? items
                      : items
                          .where((i) => i.name
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()))
                          .toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.packageOpen,
                              size: 48, color: CookestTokens.colorMutedLight),
                          const SizedBox(height: 12),
                          Text(
                            'No items found',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                    color: CookestTokens.colorHeadingLight),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Add items using the + button',
                            style: TextStyle(
                                color: CookestTokens.colorMutedLight),
                          ),
                        ],
                      ),
                    );
                  }

                  final groups = <String, List<InventoryItem>>{};
                  for (final item in filtered) {
                    groups.putIfAbsent(item.location, () => []).add(item);
                  }

                  return ListView(
                    children: groups.entries.map((entry) {
                      final label = entry.key[0].toUpperCase() +
                          entry.key.substring(1);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              label,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    color: CookestTokens.colorHeadingLight,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          ...entry.value.map((item) =>
                              _buildItemRow(item)),
                          Divider(color: CookestTokens.colorBorderLight),
                          const SizedBox(height: 4),
                        ],
                      );
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

  Widget _buildItemRow(InventoryItem item) {
    final now = DateTime.now();
    final daysUntilExpiry = item.expiryDate?.difference(now).inDays;
    final isExpired = daysUntilExpiry != null && daysUntilExpiry < 0;
    final isExpiringSoon =
        daysUntilExpiry != null && daysUntilExpiry >= 0 && daysUntilExpiry <= 5;

    final badgeVariant = isExpired
        ? CkBadgeVariant.error
        : isExpiringSoon
            ? CkBadgeVariant.warning
            : CkBadgeVariant.success;

    final statusLabel = isExpired
        ? 'Expired'
        : isExpiringSoon
            ? 'Expiring'
            : 'Fresh';

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: CookestTokens.colorStatusError,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(LucideIcons.trash2, color: Colors.white, size: 20),
      ),
      onDismissed: (_) async {
        await ref.read(inventoryRepositoryProvider).deleteItem(item.id);
        ref.invalidate(inventoryListProvider);
        ref.invalidate(expiringCountProvider);
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: CkCard(
          padding: CkCardPadding.sm,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: CookestTokens.colorHeadingLight,
                      ),
                    ),
                    Text(
                      '${item.quantity} ${item.unit}',
                      style: TextStyle(
                          fontSize: 13, color: CookestTokens.colorMutedLight),
                    ),
                  ],
                ),
              ),
              if (item.expiryDate != null) ...[
                const SizedBox(width: 8),
                Text(
                  DateFormat.MMMd().format(item.expiryDate!),
                  style: TextStyle(
                      fontSize: 13, color: CookestTokens.colorMutedLight),
                ),
              ],
              const SizedBox(width: 8),
              CkBadge(
                variant: badgeVariant,
                size: CkBadgeSize.sm,
                child: Text(statusLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
