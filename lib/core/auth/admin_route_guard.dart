import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_provider.dart';

/// Redirects non-admin users away from admin-only screens.
mixin AdminRouteGuard<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _guardAdminRoute());
  }

  void _guardAdminRoute() {
    if (!mounted) return;
    if (!ref.read(isAdminProvider)) {
      final auth = ref.read(authSessionProvider);
      context.go(auth.isMember ? '/my-profile' : '/login');
    }
  }
}
