import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/onboarding_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/recipes/screens/recipes_screen.dart';
import '../features/meal_plan/screens/meal_plan_screen.dart';
import '../features/pantry/screens/inventory_screen.dart';
import '../features/shopping_list/screens/shopping_list_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/chat/screens/chat_screen.dart';
import '../features/subscription/screens/paywall_screen.dart';
import '../features/recipes/screens/recipe_detail_screen.dart';
import '../features/recipes/screens/create_recipe_screen.dart';
import '../shared/theme/shadcn_theme.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    navigatorKey: _rootNavigatorKey,
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';
      final isSplash = state.matchedLocation == '/splash';

      if (isSplash) return null;
      if (!isAuthenticated && !isLoggingIn) return '/login';
      if (isAuthenticated && isLoggingIn) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/recipes/create', builder: (context, state) => const CreateRecipeScreen()),
      GoRoute(path: '/recipes/:id', builder: (context, state) => RecipeDetailScreen(recipeId: state.pathParameters['id']!)),
      GoRoute(path: '/chat', builder: (context, state) => const ChatScreen()),
      GoRoute(path: '/paywall', builder: (context, state) => const PaywallScreen()),
      GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => _AppShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          GoRoute(path: '/meals', builder: (context, state) => const MealPlanScreen()),
          GoRoute(path: '/recipes', builder: (context, state) => const RecipesScreen()),
          GoRoute(path: '/pantry', builder: (context, state) => const InventoryScreen()),
          GoRoute(path: '/groceries', builder: (context, state) => const ShoppingListScreen()),
        ],
      ),
    ],
  );
});

class _AppShell extends StatelessWidget {
  final String location;
  final Widget child;
  const _AppShell({required this.location, required this.child});

  static const _tabs = [
    (icon: LucideIcons.home, label: 'Home', path: '/'),
    (icon: LucideIcons.calendarDays, label: 'Meals', path: '/meals'),
    (icon: LucideIcons.bookOpen, label: 'Recipes', path: '/recipes'),
    (icon: LucideIcons.package, label: 'Pantry', path: '/pantry'),
    (icon: LucideIcons.shoppingCart, label: 'Groceries', path: '/groceries'),
  ];

  int get _currentIndex {
    for (var i = 0; i < _tabs.length; i++) {
      if (_tabs[i].path == '/') {
        if (location == '/') return i;
      } else if (location.startsWith(_tabs[i].path)) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(top: BorderSide(color: AppTheme.divider, width: 1)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_tabs.length, (i) {
                final isActive = _currentIndex == i;
                final tab = _tabs[i];
                return Expanded(
                  child: InkWell(
                    onTap: () => GoRouter.of(context).go(tab.path),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 150),
                          transitionBuilder: (child, animation) =>
                              FadeTransition(opacity: animation, child: child),
                          child: Icon(
                            tab.icon,
                            key: ValueKey(isActive),
                            size: 22,
                            color: isActive ? AppTheme.sage : AppTheme.textCaption,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 150),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: isActive ? AppTheme.sage : AppTheme.textCaption,
                          ),
                          child: Text(tab.label),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
