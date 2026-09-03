import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../service/token_storage.dart';
import '../domain/auth_repository.dart';
import '../domain/user_entity.dart';
import 'auth_api.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required TokenStorage tokenStorage,
    required AuthApi authApi,
  }) : _tokenStorage = tokenStorage,
       _authApi = authApi;

  final TokenStorage _tokenStorage;
  final AuthApi _authApi;

  @override
  Future<String?> readToken() {
    return _tokenStorage.readToken();
  }

  @override
  Future<void> saveToken(String token) {
    return _tokenStorage.saveToken(token);
  }

  @override
  Future<void> clearSession() {
    return _tokenStorage.clearToken();
  }

  @override
  Future<UserModel> getCurrentUser({required String token}) {
    return _authApi.getCurrentUser(token: token);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    tokenStorage: ref.watch(tokenStorageProvider),
    authApi: ref.watch(authApiProvider),
  );
});
