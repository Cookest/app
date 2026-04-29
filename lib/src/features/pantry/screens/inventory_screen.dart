import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../repositories/inventory_repository.dart';
import '../models/inventory_item.dart';
import '../../../shared/theme/shadcn_theme.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final Set<String> _expandedSections = {'fridge', 'pantry', 'freezer', 'other'};
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
            backgroundColor: AppTheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text('Add Item', style: GoogleFonts.playfairDisplay(fontSize: 20, color: AppTheme.darkGreen)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Item Name',
                      labelStyle: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: quantityController,
                          decoration: InputDecoration(
                            labelText: 'Quantity',
                            labelStyle: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: unitController,
                          decoration: InputDecoration(
                            labelText: 'Unit',
                            labelStyle: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: location,
                    decoration: InputDecoration(
                      labelText: 'Location',
                      labelStyle: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted),
                    ),
                    items: ['fridge', 'pantry', 'freezer'].map((loc) {
                      return DropdownMenuItem(value: loc, child: Text(loc[0].toUpperCase() + loc.substring(1)));
                    }).toList(),
                    onChanged: (v) => setDialogState(() => location = v!),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      expiryDate == null ? 'Set Expiry Date' : 'Expires: ${DateFormat.yMd().format(expiryDate!)}',
                      style: GoogleFonts.inter(fontSize: 14, color: AppTheme.darkGreen),
                    ),
                    trailing: const Icon(LucideIcons.calendar, color: AppTheme.sage),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 7)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) setDialogState(() => expiryDate = date);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textMuted)),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isEmpty) return;
                  await ref.read(inventoryRepositoryProvider).addItem({
                    'name': nameController.text,
                    'quantity': double.tryParse(quantityController.text) ?? 1.0,
                    'unit': unitController.text,
                    'location': location,
                    if (expiryDate != null) 'expiry_date': expiryDate!.toIso8601String(),
                  });
                  ref.invalidate(inventoryListProvider);
                  ref.invalidate(expiringCountProvider);
                  if (context.mounted) Navigator.pop(context);
                },
                child: Text('Add', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
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

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: Text(
          'Pantry',
          style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.darkGreen),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search items',
                prefixIcon: const Icon(LucideIcons.search, size: 18, color: AppTheme.textCaption),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.sage, width: 1.5)),
                filled: true,
                fillColor: AppTheme.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                hintStyle: GoogleFonts.inter(fontSize: 14, color: AppTheme.textCaption),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          Expanded(
            child: inventoryAsync.when(
              data: (items) {
                final filtered = _searchQuery.isEmpty
                    ? items
                    : items.where((i) => i.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.packageOpen, size: 48, color: AppTheme.textCaption),
                        const SizedBox(height: 12),
                        Text('No items found', style: GoogleFonts.inter(fontSize: 15, color: AppTheme.textMuted)),
                      ],
                    ),
                  );
                }

                final groups = <String, List<InventoryItem>>{};
                for (final item in filtered) {
                  groups.putIfAbsent(item.location, () => []).add(item);
                }

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  children: groups.entries.map((entry) => _buildSection(entry.key, entry.value)).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.sage)),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        backgroundColor: AppTheme.sage,
        foregroundColor: AppTheme.surface,
        elevation: 2,
        child: const Icon(LucideIcons.plus),
      ),
    );
  }

  Widget _buildSection(String location, List<InventoryItem> items) {
    final isExpanded = _expandedSections.contains(location);
    final label = location[0].toUpperCase() + location.substring(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() {
            if (isExpanded) {
              _expandedSections.remove(location);
            } else {
              _expandedSections.add(location);
            }
          }),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.darkGreen),
                ),
                const Spacer(),
                Icon(
                  isExpanded ? LucideIcons.chevronDown : LucideIcons.chevronRight,
                  size: 18,
                  color: AppTheme.textMuted,
                ),
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

  Widget _buildItemRow(InventoryItem item) {
    final now = DateTime.now();
    final daysUntilExpiry = item.expiryDate != null ? item.expiryDate!.difference(now).inDays : null;
    final isExpiringSoon = daysUntilExpiry != null && daysUntilExpiry <= 5 && daysUntilExpiry >= 0;
    final isExpiredToday = daysUntilExpiry != null && daysUntilExpiry <= 1;
    final isExpired = daysUntilExpiry != null && daysUntilExpiry < 0;

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.destructive,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(LucideIcons.trash2, color: Colors.white, size: 20),
      ),
      onDismissed: (_) async {
        await ref.read(inventoryRepositoryProvider).deleteItem(item.id);
        ref.invalidate(inventoryListProvider);
        ref.invalidate(expiringCountProvider);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: (isExpiredToday && !isExpired) ? AppTheme.amberVeryLight : AppTheme.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            if (isExpiringSoon || isExpired)
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: isExpired ? AppTheme.destructive : AppTheme.amber,
                  shape: BoxShape.circle,
                ),
              ),
            Expanded(
              child: Text(
                item.name,
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.darkGreen),
              ),
            ),
            Text(
              '${item.quantity} ${item.unit}',
              style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted),
            ),
            if (item.expiryDate != null) ...[
              const SizedBox(width: 12),
              Text(
                DateFormat.MMMd().format(item.expiryDate!),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: isExpired ? AppTheme.destructive : (isExpiringSoon ? AppTheme.amber : AppTheme.textMuted),
                  fontWeight: isExpiringSoon || isExpired ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

