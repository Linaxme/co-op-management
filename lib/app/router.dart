import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/auth/auth_provider.dart';
import '../core/auth/auth_session.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/shell/shell_screen.dart';
import '../features/member_shell/member_shell_screen.dart';
import '../features/deposits/add_deposit_screen.dart';
import '../features/members/add_member_screen.dart';
import '../features/members/member_detail_screen.dart';
import '../features/trash/trash_screen.dart';
import '../features/settings/settings_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ref.watch(authRefreshNotifierProvider);

  return GoRouter(
    refreshListenable: refresh,
    initialLocation: '/',
    redirect: (context, state) {
      final authAsync = ref.read(authProvider);
      if (authAsync.isLoading) return null;

      final auth = authAsync.value ?? AuthSession.unauthenticated;
      final path = state.matchedLocation;
      final loggingIn = path == '/login';
      final signingUp = path == '/signup';

      if (!auth.isAuthenticated) {
        if (loggingIn || signingUp) return null;
        return '/login';
      }

      if (loggingIn || signingUp) {
        return auth.isAdmin ? '/' : '/my-dashboard';
      }

      if (auth.isMember) {
        const allowed = {
          '/my-dashboard',
          '/my-due',
          '/member-collect',
          '/my-profile',
          '/member-settings',
        };
        if (!allowed.contains(path) &&
            !path.startsWith('/member/') &&
            path != '/login') {
          return '/my-dashboard';
        }
        if (path.startsWith('/member/')) {
          final id = state.pathParameters['id'];
          if (id != null && id != auth.memberUuid) {
            return '/my-dashboard';
          }
        }
      }

      if (auth.isAdmin) {
        if (path.startsWith('/my-') || path == '/member-settings') {
          return '/';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const ShellScreen(),
        routes: [
          GoRoute(
            path: 'add-deposit',
            builder: (context, state) {
              final memberUuid = state.uri.queryParameters['memberUuid'];
              return AddDepositScreen(memberUuid: memberUuid);
            },
          ),
          GoRoute(
            path: 'edit-deposit/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return AddDepositScreen(depositUuid: id);
            },
          ),
          GoRoute(
            path: 'add-member',
            builder: (context, state) => const AddMemberScreen(),
          ),
          GoRoute(
            path: 'edit-member/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return AddMemberScreen(memberUuid: id);
            },
          ),
          GoRoute(
            path: 'member/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return MemberDetailScreen(memberUuid: id);
            },
          ),
          GoRoute(
            path: 'trash',
            builder: (context, state) => const TrashScreen(),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/my-dashboard',
        builder: (context, state) =>
            const MemberShellScreen(initialTab: MemberShellTab.dashboard),
      ),
      GoRoute(
        path: '/my-due',
        builder: (context, state) =>
            const MemberShellScreen(initialTab: MemberShellTab.due),
      ),
      GoRoute(
        path: '/member-collect',
        builder: (context, state) =>
            const MemberShellScreen(initialTab: MemberShellTab.collect),
      ),
      GoRoute(
        path: '/my-profile',
        builder: (context, state) =>
            const MemberShellScreen(initialTab: MemberShellTab.profile),
      ),
      GoRoute(
        path: '/member-settings',
        builder: (context, state) =>
            const MemberShellScreen(initialTab: MemberShellTab.settings),
      ),
    ],
  );
});
