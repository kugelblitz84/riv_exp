import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod/riverpod.dart';

import '../core/session/application/session_controller.dart';
import '../core/session/domain/auth_state.dart';
import './app_pages.dart';
import './app_routes.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier();
  ref
    ..onDispose(refreshNotifier.dispose)
    ..listen<AsyncValue<AuthState>>(
      sessionProvider,
      (_, _) => refreshNotifier.refresh(),
    );

  return GoRouter(
    initialLocation: AppRoutes.bootstrap,
    refreshListenable: refreshNotifier,
    redirect: (context, routerState) {
      final session = ref.read(sessionProvider);
      final location = routerState.matchedLocation;

      if (session.isLoading || session.hasError) {
        return location == AppRoutes.bootstrap ? null : AppRoutes.bootstrap;
      }

      final authState = session.value;
      final isAuthRoute =
          location == AppRoutes.login || location == AppRoutes.register;

      if (authState is Authenticated) {
        return location == AppRoutes.bootstrap || isAuthRoute
            ? AppRoutes.home
            : null;
      }

      return isAuthRoute ? null : AppRoutes.login;
    },
    routes: AppPages.routes,
  );
});

class _RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}
