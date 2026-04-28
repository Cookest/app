import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../repositories/auth_repository.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // Form Data
  int _householdSize = 1;
  String _cookingSkill = 'intermediate';
  List<String> _dietaryRestrictions = [];
  List<String> _allergies = [];
  List<String> _healthGoals = [];
  String _dietType = 'none';
  int _availableTime = 30;
  String _energyLevel = 'medium';

  final List<String> _cookingSkills = ['beginner', 'intermediate', 'advanced'];
  final List<String> _dietTypes = ['none', 'keto', 'mediterranean', 'vegan', 'vegetarian', 'paleo'];
  final List<String> _energyLevels = ['low', 'medium', 'high'];
  final List<String> _commonDietary = ['Gluten-Free', 'Dairy-Free', 'Low-Carb', 'Low-Fat', 'Halal', 'Kosher'];
  final List<String> _commonGoals = ['Weight Loss', 'Muscle Gain', 'Maintenance', 'Energy Boost', 'Healthier Eating'];

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).saveOnboarding({
        'household_size': _householdSize,
        'cooking_skill': _cookingSkill,
        'dietary_restrictions': _dietaryRestrictions,
        'allergies': _allergies,
        'health_goals': _healthGoals,
        'diet_type': _dietType,
        'available_time_minutes': _availableTime,
        'energy_level_default': _energyLevel,
      });
      if (mounted) context.go('/');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      setState(() => _isLoading = false);
    }
  }

  void _nextPage() {
    if (_currentStep < 5) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _submit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tailor Your Experience'),
        actions: [
          TextButton(
            onPressed: () => context.go('/'),
            child: const Text('Skip'),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(value: (_currentStep + 1) / 6),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentStep = i),
              children: [
                _buildStep(
                  title: 'Household Info',
                  child: Column(
                    children: [
                      const Text('How many people are you cooking for?'),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(onPressed: () => setState(() => _householdSize = (_householdSize > 1) ? _householdSize - 1 : 1), icon: const Icon(Icons.remove_circle_outline)),
                          Text('$_householdSize', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          IconButton(onPressed: () => setState(() => _householdSize++), icon: const Icon(Icons.add_circle_outline)),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const Text('What is your cooking skill?'),
                      const SizedBox(height: 16),
                      ..._cookingSkills.map((skill) => RadioListTile<String>(
                        title: Text(skill[0].toUpperCase() + skill.substring(1)),
                        value: skill,
                        groupValue: _cookingSkill,
                        onChanged: (v) => setState(() => _cookingSkill = v!),
                      )),
                    ],
                  ),
                ),
                _buildStep(
                  title: 'Diet & Preferences',
                  child: Column(
                    children: [
                      const Text('Select your diet type:'),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        children: _dietTypes.map((type) => ChoiceChip(
                          label: Text(type),
                          selected: _dietType == type,
                          onSelected: (s) => setState(() => _dietType = type),
                        )).toList(),
                      ),
                      const SizedBox(height: 32),
                      const Text('Dietary Restrictions:'),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        children: _commonDietary.map((r) => FilterChip(
                          label: Text(r),
                          selected: _dietaryRestrictions.contains(r),
                          onSelected: (s) => setState(() => s ? _dietaryRestrictions.add(r) : _dietaryRestrictions.remove(r)),
                        )).toList(),
                      ),
                    ],
                  ),
                ),
                _buildStep(
                  title: 'Health Goals',
                  child: Column(
                    children: [
                      const Text('What are your health goals?'),
                      const SizedBox(height: 16),
                      ..._commonGoals.map((goal) => CheckboxListTile(
                        title: Text(goal),
                        value: _healthGoals.contains(goal),
                        onChanged: (s) => setState(() => s! ? _healthGoals.add(goal) : _healthGoals.remove(goal)),
                      )),
                    ],
                  ),
                ),
                _buildStep(
                  title: 'Allergies',
                  child: Column(
                    children: [
                      const Text('Do you have any allergies?'),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'e.g. Peanuts, Shellfish (comma separated)',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (v) => setState(() => _allergies = v.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()),
                      ),
                    ],
                  ),
                ),
                _buildStep(
                  title: 'Time & Energy',
                  child: Column(
                    children: [
                      const Text('Average cooking time (minutes):'),
                      Slider(
                        value: _availableTime.toDouble(),
                        min: 10,
                        max: 120,
                        divisions: 11,
                        label: '$_availableTime min',
                        onChanged: (v) => setState(() => _availableTime = v.toInt()),
                      ),
                      const SizedBox(height: 32),
                      const Text('Default energy level after work:'),
                      const SizedBox(height: 16),
                      ..._energyLevels.map((level) => RadioListTile<String>(
                        title: Text(level[0].toUpperCase() + level.substring(1)),
                        value: level,
                        groupValue: _energyLevel,
                        onChanged: (v) => setState(() => _energyLevel = v!),
                      )),
                    ],
                  ),
                ),
                _buildStep(
                  title: 'All Set!',
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 100, color: Colors.green),
                      SizedBox(height: 24),
                      Text('We\'re ready to customize your meal plan.', textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _nextPage,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isLoading 
                  ? const CircularProgressIndicator()
                  : Text(_currentStep == 5 ? 'Get Started' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep({required String title, required Widget child}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}
