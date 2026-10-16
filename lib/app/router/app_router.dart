import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/security/secure_storage_service.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/auth/auth_state.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/chat/main_chat_screen.dart';
import '../../presentation/screens/documents/documents_screen.dart';
import '../../presentation/screens/memory/memory_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';

/// Bridges Stream from AuthBloc to a ChangeNotifier for GoRouter's refreshListenable
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  final SecureStorageService _storageService;
  final AuthBloc _authBloc;
  late final GoRouterRefreshStream _refreshStream;

  AppRouter(this._storageService, this._authBloc) {
    _refreshStream = GoRouterRefreshStream(_authBloc.stream);
  }

  void dispose() {
    _refreshStream.dispose();
  }

  late final GoRouter router = GoRouter(
    initialLocation: '/chat',
    refreshListenable: _refreshStream,
    redirect: (BuildContext context, GoRouterState state) async {
      final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      // 1. Check live AuthBloc state
      final authState = _authBloc.state;
      if (authState is Unauthenticated) {
        if (!isAuthRoute) return '/login';
        return null;
      }
      if (authState is Authenticated) {
        if (isAuthRoute) return '/chat';
        return null;
      }

      // 2. Fallback to secure storage tokens (e.g. cold start before AuthBloc finishes check)
      final token = await _storageService.getAccessToken();
      final hasToken = token != null && token.isNotEmpty;

      if (!hasToken && !isAuthRoute) {
        return '/login';
      }

      if (hasToken && isAuthRoute) {
        return '/chat';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) => const MainChatScreen(),
      ),
      GoRoute(
        path: '/documents',
        name: 'documents',
        builder: (context, state) => const DocumentsScreen(),
      ),
      GoRoute(
        path: '/memory',
        name: 'memory',
        builder: (context, state) => const MemoryScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
