import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository_impl.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_state.dart';
import '../domain/session_exception.dart';
import '../domain/user_entity.dart';

class SessionController extends AsyncNotifier<AuthState> {
  int _operation = 0;

  AuthRepository get _repository {
    return ref.read(authRepositoryProvider);
  }

  @override
  Future<AuthState> build() async {
    final repository = ref.watch(authRepositoryProvider);

    return _restoreSession(repository);
  }

  Future<AuthState> _restoreSession(AuthRepository repository) async {
    final storedToken = (await repository.readToken())?.trim();

    if (storedToken == null || storedToken.isEmpty) {
      return const Unauthenticated();
    }

    try {
      final user = await repository.getCurrentUser(token: storedToken);

      return Authenticated(user: user);
    } on InvalidSessionException {
      await repository.clearSession();
      return const Unauthenticated();
    }
  }

  Future<void> retryBootstrap() async {
    final operation = ++_operation;

    state = const AsyncLoading();

    final result = await AsyncValue.guard(() => _restoreSession(_repository));

    if (operation != _operation) return;

    state = result;
  }

  /// Establishes a session after a successful login.
  ///
  /// Prefer supplying [user] if the login endpoint
  /// already returns the current user.
  Future<void> establishSession({
    required String token,
    UserModel? user,
  }) async {
    final normalizedToken = token.trim();

    if (normalizedToken.isEmpty) {
      throw ArgumentError.value(token, 'token', 'Token cannot be empty');
    }

    final operation = ++_operation;

    state = const AsyncLoading();

    final result = await AsyncValue.guard<AuthState>(() async {
      try {
        final authenticatedUser =
            user ?? await _repository.getCurrentUser(token: normalizedToken);

        await _repository.saveToken(normalizedToken);

        return Authenticated(user: authenticatedUser);
      } on InvalidSessionException {
        await _repository.clearSession();
        return const Unauthenticated();
      }
    });

    if (operation != _operation) return;

    state = result;
  }

  Future<void> signIn({required String token, UserModel? user}) async {
    await establishSession(token: token, user: user);
  }

  Future<void> signOut() async {
    final operation = ++_operation;

    state = const AsyncLoading();

    try {
      await _repository.clearSession();

      if (operation != _operation) return;

      state = const AsyncData(Unauthenticated());
    } catch (error, stackTrace) {
      if (operation != _operation) return;

      state = AsyncError(error, stackTrace);
    }
  }
}

final sessionProvider = AsyncNotifierProvider<SessionController, AuthState>(
  SessionController.new,
);

// int num = 0;

// void updateNum() {
//   num++;
// }

// final numProvider = Provider<int>((ref) {
//   return num;
// });
