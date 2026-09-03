import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/session/presentation/session_gate.dart';
import '../routes/router_provider.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      builder: (context, child) {
        return SessionGate(
          authenticatedBuilder: (_) => child ?? const SizedBox.shrink(),
          unauthenticatedBuilder: (_) => child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
