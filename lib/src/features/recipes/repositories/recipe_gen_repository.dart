import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../models/generated_recipe.dart';

class RecipeGenRepository {
  final Dio _dio;

  RecipeGenRepository(this._dio);

  /// Calls POST /api/recipes/generate.
  ///
  /// The server runs up to 3 generate→score→refine iterations silently and
  /// returns the best result. Expect 30–120 s on CPU-only hardware.
  Future<GeneratedRecipe> generate({
    required bool usePantry,
    String? cuisineHint,
    int? maxMinutes,
  }) async {
    final response = await _dio.post(
      '/api/recipes/generate',
      data: {
        'use_pantry': usePantry,
        if (cuisineHint != null && cuisineHint.isNotEmpty)
          'cuisine_hint': cuisineHint,
        if (maxMinutes != null) 'max_minutes': maxMinutes,
      },
      options: Options(
        // Generation + up to 3 Ollama calls can take several minutes on CPU
        receiveTimeout: const Duration(minutes: 6),
        sendTimeout: const Duration(seconds: 30),
      ),
    );
    return GeneratedRecipe.fromJson(response.data as Map<String, dynamic>);
  }
}

final recipeGenRepositoryProvider = Provider<RecipeGenRepository>((ref) {
  return RecipeGenRepository(ref.watch(dioProvider));
});

// ── State notifier ────────────────────────────────────────────────────────────

sealed class RecipeGenState {
  const RecipeGenState();
}

class RecipeGenIdle extends RecipeGenState {
  const RecipeGenIdle();
}

class RecipeGenLoading extends RecipeGenState {
  const RecipeGenLoading();
}

class RecipeGenSuccess extends RecipeGenState {
  final GeneratedRecipe recipe;
  const RecipeGenSuccess(this.recipe);
}

class RecipeGenError extends RecipeGenState {
  final String message;
  const RecipeGenError(this.message);
}

class RecipeGenNotifier extends StateNotifier<RecipeGenState> {
  final RecipeGenRepository _repo;

  RecipeGenNotifier(this._repo) : super(const RecipeGenIdle());

  Future<void> generate({
    required bool usePantry,
    String? cuisineHint,
    int? maxMinutes,
  }) async {
    state = const RecipeGenLoading();
    try {
      final recipe = await _repo.generate(
        usePantry: usePantry,
        cuisineHint: cuisineHint,
        maxMinutes: maxMinutes,
      );
      state = RecipeGenSuccess(recipe);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] as String? ??
          'Erro ao gerar receita. Tenta novamente.';
      state = RecipeGenError(msg);
    } catch (e) {
      state = RecipeGenError('Erro inesperado: $e');
    }
  }

  void reset() => state = const RecipeGenIdle();
}

final recipeGenProvider =
    StateNotifierProvider<RecipeGenNotifier, RecipeGenState>((ref) {
  return RecipeGenNotifier(ref.watch(recipeGenRepositoryProvider));
});
