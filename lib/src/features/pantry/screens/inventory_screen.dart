import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../repositories/inventory_repository.dart';
import '../models/inventory_item.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _locations = ['all', 'fridge', 'pantry', 'freezer'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _locations.length, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
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
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Item'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Item Name'),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: quantityController,
                          decoration: const InputDecoration(labelText: 'Quantity'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: unitController,
                          decoration: const InputDecoration(labelText: 'Unit (e.g. g, pcs)'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: location,
                    decoration: const InputDecoration(labelText: 'Location'),
                    items: ['fridge', 'pantry', 'freezer'].map((loc) {
                      return DropdownMenuItem(value: loc, child: Text(loc[0].toUpperCase() + loc.substring(1)));
                    }).toList(),
                    onChanged: (v) => setState(() => location = v!),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: Text(expiryDate == null ? 'Set Expiry Date' : 'Expires: ${DateFormat.yMd().format(expiryDate!)}'),
                    trailing: const Icon(LucideIcons.calendar),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 7)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() => expiryDate = date);
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
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
                child: const Text('Add'),
              ),
            ],
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inventoryAsync = ref.watch(inventoryListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _locations.map((loc) => Tab(text: loc == 'all' ? 'All Items' : loc[0].toUpperCase() + loc.substring(1))).toList(),
        ),
      ),
      body: inventoryAsync.when(
        data: (items) {
          final currentLocation = _locations[_tabController.index];
          final filteredItems = currentLocation == 'all' 
              ? items 
              : items.where((i) => i.location == currentLocation).toList();
          
          filteredItems.sort((a, b) {
            if (a.expiryDate == null && b.expiryDate == null) return 0;
            if (a.expiryDate == null) return 1;
            if (b.expiryDate == null) return -1;
            return a.expiryDate!.compareTo(b.expiryDate!);
          });

          if (filteredItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.packageOpen, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text('No items found'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredItems.length,
            itemBuilder: (context, index) => _buildInventoryItem(filteredItems[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        backgroundColor: Colors.green,
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
    );
  }

  Widget _buildInventoryItem(InventoryItem item) {
    final bool isExpiringSoon = item.expiryDate != null && item.expiryDate!.difference(DateTime.now()).inDays <= 3;
    final bool isExpired = item.expiryDate != null && item.expiryDate!.isBefore(DateTime.now());

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
        await ref.read(inventoryRepositoryProvider).deleteItem(item.id);
        ref.invalidate(inventoryListProvider);
        ref.invalidate(expiringCountProvider);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isExpired || isExpiringSoon 
              ? BorderSide(color: isExpired ? Colors.red : Colors.orange, width: 1) 
              : BorderSide.none,
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _getLocationColor(item.location).withOpacity(0.2),
            child: Icon(_getLocationIcon(item.location), color: _getLocationColor(item.location), size: 20),
          ),
          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${item.quantity} ${item.unit}'),
          trailing: item.expiryDate != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isExpired ? 'Expired' : (isExpiringSoon ? 'Expiring' : 'Expires'),
                      style: TextStyle(
                        fontSize: 10,
                        color: isExpired ? Colors.red : (isExpiringSoon ? Colors.orange : Colors.grey),
                        fontWeight: isExpired || isExpiringSoon ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    Text(
                      DateFormat.MMMd().format(item.expiryDate!),
                      style: TextStyle(
                        fontSize: 12,
                        color: isExpired ? Colors.red : (isExpiringSoon ? Colors.orange : Colors.grey.shade800),
                        fontWeight: isExpired || isExpiringSoon ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                )
              : null,
        ),
      ),
    );
  }

  Color _getLocationColor(String location) {
    switch (location) {
      case 'fridge': return Colors.blue;
      case 'freezer': return Colors.cyan;
      case 'pantry': return Colors.orange;
      default: return Colors.grey;
    }
  }

  IconData _getLocationIcon(String location) {
    switch (location) {
      case 'fridge': return LucideIcons.refrigerator;
      case 'freezer': return LucideIcons.snowflake;
      case 'pantry': return LucideIcons.package;
      default: return LucideIcons.box;
    }
  }
}
