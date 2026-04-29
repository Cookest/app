import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      final isOnboarding = state.matchedLocation == '/onboarding';

      if (isSplash) return null;

      if (!isAuthenticated && !isLoggingIn) {
        return '/login';
      }

      if (isAuthenticated && isLoggingIn) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/recipes/create',
        builder: (context, state) => const CreateRecipeScreen(),
      ),
      GoRoute(
        path: '/recipes/:id',
        builder: (context, state) => RecipeDetailScreen(recipeId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: '/paywall',
        builder: (context, state) => const PaywallScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return Scaffold(
            body: child,
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _calculateSelectedIndex(state.matchedLocation),
              onTap: (index) => _onItemTapped(index, context),
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.green.shade700,
              unselectedItemColor: Colors.grey,
              items: const [
                BottomNavigationBarItem(icon: Icon(LucideIcons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(LucideIcons.search), label: 'Recipes'),
                BottomNavigationBarItem(icon: Icon(LucideIcons.calendar), label: 'Plan'),
                BottomNavigationBarItem(icon: Icon(LucideIcons.package), label: 'Pantry'),
                BottomNavigationBarItem(icon: Icon(LucideIcons.shoppingCart), label: 'Shop'),
                BottomNavigationBarItem(icon: Icon(LucideIcons.user), label: 'Profile'),
              ],
            ),
          );
        },
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          GoRoute(path: '/recipes', builder: (context, state) => const RecipesScreen()),
          GoRoute(path: '/plan', builder: (context, state) => const MealPlanScreen()),
          GoRoute(path: '/inventory', builder: (context, state) => const InventoryScreen()),
          GoRoute(path: '/shopping-list', builder: (context, state) => const ShoppingListScreen()),
          GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
        ],
      ),
    ],
  );
});

int _calculateSelectedIndex(String location) {
  if (location == '/') return 0;
  if (location == '/recipes') return 1;
  if (location == '/plan') return 2;
  if (location == '/inventory') return 3;
  if (location == '/shopping-list') return 4;
  if (location == '/profile') return 5;
  return 0;
}

void _onItemTapped(int index, BuildContext context) {
  switch (index) {
    case 0: GoRouter.of(context).go('/'); break;
    case 1: GoRouter.of(context).go('/recipes'); break;
    case 2: GoRouter.of(context).go('/plan'); break;
    case 3: GoRouter.of(context).go('/inventory'); break;
    case 4: GoRouter.of(context).go('/shopping-list'); break;
    case 5: GoRouter.of(context).go('/profile'); break;
  }
}
