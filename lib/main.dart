import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cookest_ui/cookest_ui.dart';
import 'src/core/router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: CookestApp(),
    ),
  );
}

class CookestApp extends ConsumerWidget {
  const CookestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Cookest',
      debugShowCheckedModeBanner: false,
      theme: CookestTheme.light,
      darkTheme: CookestTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
