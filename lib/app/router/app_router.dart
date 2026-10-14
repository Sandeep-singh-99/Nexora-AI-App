import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/security/secure_storage_service.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/chat/main_chat_screen.dart';
import '../../presentation/screens/documents/documents_screen.dart';
import '../../presentation/screens/memory/memory_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';

class AppRouter {
  final SecureStorageService _storageService;

  AppRouter(this._storageService);

  late final GoRouter router = GoRouter(
    initialLocation: '/chat',
    redirect: (BuildContext context, GoRouterState state) async {
      final token = await _storageService.getAccessToken();
      final isAuthenticated = token != null && token.isNotEmpty;
      final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      if (isAuthenticated && isAuthRoute) {
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
