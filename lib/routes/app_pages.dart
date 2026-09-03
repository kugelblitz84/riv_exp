import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/session/presentation/bootstrap_page.dart';
import '../features/LOGIN/login_page.dart';
import './app_routes.dart';

class AppPages {
  static final routes = <RouteBase>[
    GoRoute(
      path: AppRoutes.bootstrap,
      builder: (context, state) => const BootstrapPage(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const _PlaceholderPage(title: 'Home'),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const _PlaceholderPage(title: 'Register'),
    ),
  ];
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(title)));
  }
}
