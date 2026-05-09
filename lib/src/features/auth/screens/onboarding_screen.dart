import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cookest_ui/cookest_ui.dart';
import '../repositories/auth_repository.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  final Set<String> _dietaryRestrictions = {};
  String _cookingSkill = 'intermediate';
  double _householdSize = 2;

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).saveOnboarding({
        'dietary_restrictions': _dietaryRestrictions.toList(),
        'cooking_skill': _cookingSkill,
        'household_size': _householdSize.round(),
        'allergies': [],
        'health_goals': [],
        'diet_type': 'none',
        'available_time_minutes': 30,
        'energy_level': 'medium',
      });
      if (mounted) context.go('/');
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _goTo(int page) {
    _pageController.animateToPage(page, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CkProgress(
              value: (_currentPage + 1) / 3 * 100,
              color: CkProgressColor.primary,
              size: CkProgressSize.sm,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Step ${_currentPage + 1} of 3',
                      style: GoogleFonts.inter(fontSize: 14, color: CookestTokens.colorMutedLight)),
                  TextButton(onPressed: () => context.go('/'), child: const Text('Skip')),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [_buildPage0(), _buildPage1(), _buildPage2()],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    CkButton(
                      variant: CkButtonVariant.secondary,
                      onPressed: () => _goTo(_currentPage - 1),
                      child: const Text('Back'),
                    ),
                  const Spacer(),
                  if (_currentPage < 2)
                    CkButton(
                      onPressed: () => _goTo(_currentPage + 1),
                      child: const Text('Next'),
                    ),
                  if (_currentPage == 2)
                    CkButton(
                      onPressed: _submit,
                      loading: _isLoading,
                      child: const Text('Get started'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage0() {
    const options = ['Vegetarian', 'Vegan', 'Gluten-free', 'Dairy-free'];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dietary preferences',
              style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Select all that apply',
              style: GoogleFonts.inter(fontSize: 14, color: CookestTokens.colorMutedLight)),
          const SizedBox(height: 24),
          ...options.map((opt) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CkToggle(
                  value: _dietaryRestrictions.contains(opt),
                  label: opt,
                  onChanged: (v) => setState(() => v
                      ? _dietaryRestrictions.add(opt)
                      : _dietaryRestrictions.remove(opt)),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildPage1() {
    const skills = ['Beginner', 'Intermediate', 'Advanced'];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your cooking level',
              style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('How experienced are you?',
              style: GoogleFonts.inter(fontSize: 14, color: CookestTokens.colorMutedLight)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: skills
                .map((s) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: CkButton(
                        variant: _cookingSkill == s.toLowerCase()
                            ? CkButtonVariant.primary
                            : CkButtonVariant.secondary,
                        onPressed: () => setState(() => _cookingSkill = s.toLowerCase()),
                        child: Text(s),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPage2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Household size',
              style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Including yourself',
              style: GoogleFonts.inter(fontSize: 14, color: CookestTokens.colorMutedLight)),
          const SizedBox(height: 24),
          CkSlider(
            value: _householdSize,
            min: 1,
            max: 8,
            step: 1,
            label: 'People',
            showValue: true,
            onChanged: (v) => setState(() => _householdSize = v),
          ),
          const SizedBox(height: 12),
          Text('${_householdSize.round()} people',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
