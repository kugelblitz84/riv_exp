import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riv_exp/app/app.dart';
import 'package:riv_exp/core/session/data/auth_api.dart';
import 'package:riv_exp/core/session/data/auth_repository_impl.dart';
import 'package:riv_exp/core/session/domain/auth_repository.dart';
import 'package:riv_exp/core/session/domain/session_exception.dart';
import 'package:riv_exp/core/session/domain/user_entity.dart';

const testUser = UserModel(
  id: 'user-1',
  email: 'user@example.com',
  name: 'Test User',
  role: Role.customer,
);

void main() {
  testWidgets('missing token routes to login', (tester) async {
    final repository = FakeAuthRepository();

    await pumpApp(tester, repository);

    expect(find.text('Login'), findsOneWidget);
    expect(repository.currentUserRequests, 0);
  });

  testWidgets('login result is committed to the global session', (
    tester,
  ) async {
    final repository = FakeAuthRepository();
    final authApi = FakeAuthApi();

    await pumpApp(tester, repository, authApi: authApi);
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(repository.token, 'login-token');
    expect(authApi.loginRequests, 1);
  });

  testWidgets('saved token is validated and restores the user', (tester) async {
    final repository = FakeAuthRepository(token: 'stored-token');

    await pumpApp(tester, repository);

    expect(find.text('Home'), findsOneWidget);
    expect(repository.currentUserRequests, 1);
    expect(repository.token, 'stored-token');
  });

  testWidgets('invalid saved token is cleared and routes to login', (
    tester,
  ) async {
    final repository = FakeAuthRepository(
      token: 'expired-token',
      currentUserError: const InvalidSessionException(),
    );

    await pumpApp(tester, repository);

    expect(find.text('Login'), findsOneWidget);
    expect(repository.token, isNull);
  });

  testWidgets('temporary bootstrap failure retains token and can retry', (
    tester,
  ) async {
    final repository = FakeAuthRepository(
      token: 'valid-token',
      currentUserError: StateError('network unavailable'),
    );

    await pumpApp(tester, repository);

    expect(find.text('Unable to start the application'), findsOneWidget);
    expect(repository.token, 'valid-token');

    repository.currentUserError = null;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(repository.currentUserRequests, 2);
  });
}

Future<void> pumpApp(
  WidgetTester tester,
  FakeAuthRepository repository, {
  AuthApi? authApi,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWith((ref) => repository),
        if (authApi != null) authApiProvider.overrideWith((ref) => authApi),
      ],
      child: const App(),
    ),
  );
  await tester.pumpAndSettle();
}

class FakeAuthApi implements AuthApi {
  int loginRequests = 0;

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    loginRequests++;
    return const AuthResult(token: 'login-token', user: testUser);
  }

  @override
  Future<UserModel> getCurrentUser({required String token}) async => testUser;
}

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.token, this.currentUserError});

  String? token;
  Object? currentUserError;
  int currentUserRequests = 0;

  @override
  Future<void> clearSession() async {
    token = null;
  }

  @override
  Future<UserModel> getCurrentUser({required String token}) async {
    currentUserRequests++;
    final error = currentUserError;
    if (error != null) throw error;
    return testUser;
  }

  @override
  Future<String?> readToken() async => token;

  @override
  Future<void> saveToken(String token) async {
    this.token = token;
  }
}
