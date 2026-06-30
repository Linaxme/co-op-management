import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

/// Throws if the current user is not an admin.
void requireAdmin(WidgetRef ref) {
  if (!ref.read(isAdminProvider)) {
    throw StateError('Admin access required');
  }
}

/// Returns the member UUID for the current session, or throws.
String requireMemberUuid(WidgetRef ref) {
  final uuid = ref.read(currentMemberUuidProvider);
  if (uuid == null || uuid.isEmpty) {
    throw StateError('Member session required');
  }
  return uuid;
}
