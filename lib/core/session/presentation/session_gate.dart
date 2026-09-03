import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/session_controller.dart';
import '../domain/auth_state.dart';
import 'bootstrap_error_page.dart';
import 'bootstrap_page.dart';

class SessionGate extends ConsumerWidget {
  const SessionGate({
    required this.authenticatedBuilder,
    required this.unauthenticatedBuilder,
    super.key,
  });

  final WidgetBuilder authenticatedBuilder;
  final WidgetBuilder unauthenticatedBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);

    return session.when(
      loading: () {
        return const BootstrapPage();
      },
      error: (error, stackTrace) {
        return BootstrapErrorPage(
          onRetry: () {
            ref.read(sessionProvider.notifier).retryBootstrap();
          },
        );
      },
      data: (authState) {
        return switch (authState) {
          Authenticated() => authenticatedBuilder(context),

          Unauthenticated() => unauthenticatedBuilder(context),
        };
      },
    );
  }
}
