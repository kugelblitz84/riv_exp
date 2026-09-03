import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../network/dio_provider.dart';
import '../domain/session_exception.dart';
import '../domain/user_entity.dart';

class AuthResult {
  const AuthResult({required this.token, required this.user});

  final String token;
  final UserModel user;
}

abstract interface class AuthApi {
  Future<AuthResult> login({required String email, required String password});

  Future<UserModel> getCurrentUser({required String token});
}

class DioAuthApi implements AuthApi {
  const DioAuthApi(this._dio);

  final Dio _dio;

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final responseData = response.data;

      if (responseData is! Map) {
        throw const InvalidAuthResponseException(
          'The login response must be an object.',
        );
      }

      final responseJson = Map<String, dynamic>.from(responseData);
      final payload = responseJson['data'] is Map
          ? Map<String, dynamic>.from(responseJson['data'] as Map)
          : responseJson;

      final token = payload['token'];
      final userJson = payload['user'] is Map
          ? Map<String, dynamic>.from(payload['user'] as Map)
          : payload;

      if (token is! String || token.trim().isEmpty) {
        throw const InvalidAuthResponseException(
          'The login response must include a token.',
        );
      }

      return AuthResult(token: token, user: UserModel.fromJson(userJson));
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;

      if (statusCode == 401 || statusCode == 403) {
        throw const InvalidSessionException();
      }

      rethrow;
    }
  }

  @override
  Future<UserModel> getCurrentUser({required String token}) async {
    try {
      final response = await _dio.get<Object?>(
        '/auth/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final responseData = response.data;

      if (responseData is! Map) {
        throw const InvalidAuthResponseException(
          'The current-user response must be an object.',
        );
      }

      final responseJson = Map<String, dynamic>.from(responseData);

      /*
       * This supports both response shapes:
       *
       * {
       *   "id": "...",
       *   "email": "...",
       *   "name": "...",
       *   "role": "customer"
       * }
       *
       * and:
       *
       * {
       *   "data": {
       *     "id": "...",
       *     "email": "...",
       *     "name": "...",
       *     "role": "customer"
       *   }
       * }
       */

      final nestedData = responseJson['data'];

      final userJson = nestedData is Map
          ? Map<String, dynamic>.from(nestedData)
          : responseJson;

      return UserModel.fromJson(userJson);
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;

      if (statusCode == 401 || statusCode == 403) {
        throw const InvalidSessionException();
      }

      rethrow;
    }
  }
}

final authApiProvider = Provider<AuthApi>((ref) {
  return DioAuthApi(ref.watch(dioProvider));
});
