import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../repositories/recipe_repository.dart';

class CreateRecipeScreen extends ConsumerStatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  ConsumerState<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends ConsumerState<CreateRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _timeController = TextEditingController(text: '30');
  
  String _difficulty = 'medium';
  final List<String> _ingredients = [''];
  final List<String> _instructions = [''];
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Filter empty lines
    final validIngredients = _ingredients.where((i) => i.trim().isNotEmpty).toList();
    final validInstructions = _instructions.where((i) => i.trim().isNotEmpty).toList();

    if (validIngredients.isEmpty || validInstructions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one ingredient and instruction.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(recipeRepositoryProvider).createRecipe({
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'difficulty': _difficulty,
        'total_time_min': int.parse(_timeController.text),
        'ingredients': validIngredients,
        'instructions': validInstructions,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recipe created successfully!')));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
        if (e.toString().contains('Pro')) {
          context.push('/paywall');
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Recipe', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submit,
            child: _isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Recipe Name', border: OutlineInputBorder()),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _timeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Time (mins)', border: OutlineInputBorder()),
                    validator: (v) => v == null || int.tryParse(v) == null ? 'Invalid' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _difficulty,
                    decoration: const InputDecoration(labelText: 'Difficulty', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'easy', child: Text('Easy')),
                      DropdownMenuItem(value: 'medium', child: Text('Medium')),
                      DropdownMenuItem(value: 'hard', child: Text('Hard')),
                    ],
                    onChanged: (v) => setState(() => _difficulty = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text('Ingredients', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._ingredients.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: e.value,
                      decoration: InputDecoration(hintText: 'e.g. 2 cups flour', isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                      onChanged: (v) => _ingredients[e.key] = v,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.minusCircle, color: Colors.red),
                    onPressed: () => setState(() => _ingredients.removeAt(e.key)),
                  ),
                ],
              ),
            )),
            TextButton.icon(
              onPressed: () => setState(() => _ingredients.add('')),
              icon: const Icon(LucideIcons.plus),
              label: const Text('Add Ingredient'),
            ),
            const SizedBox(height: 32),
            Text('Instructions', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._instructions.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0, right: 8.0),
                    child: Text('${e.key + 1}.', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: TextFormField(
                      initialValue: e.value,
                      maxLines: 2,
                      decoration: InputDecoration(hintText: 'Step description...', isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                      onChanged: (v) => _instructions[e.key] = v,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.minusCircle, color: Colors.red),
                    onPressed: () => setState(() => _instructions.removeAt(e.key)),
                  ),
                ],
              ),
            )),
            TextButton.icon(
              onPressed: () => setState(() => _instructions.add('')),
              icon: const Icon(LucideIcons.plus),
              label: const Text('Add Step'),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
