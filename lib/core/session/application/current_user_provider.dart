import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/auth_state.dart';
import '../domain/user_entity.dart';
import 'session_controller.dart';

final currentUserProvider = Provider<UserModel?>((ref) {
  final session = ref.watch(sessionProvider);

  final authState = session.asData?.value;

  return switch (authState) {
    Authenticated(:final user) => user,
    _ => null,
  };
});

// Any widget can now read the authenticated user:

// final user =
//     ref.watch(currentUserProvider);

// For example:

// Text(user?.name ?? 'Unknown user');
