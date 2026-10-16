import 'package:flutter_test/flutter_test.dart';
import 'package:nexora_ai_app/app/router/app_router.dart';
import 'package:nexora_ai_app/core/security/secure_storage_service.dart';
import 'package:nexora_ai_app/domain/entities/user_entity.dart';
import 'package:nexora_ai_app/domain/repositories/auth_repository.dart';
import 'package:nexora_ai_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:nexora_ai_app/presentation/blocs/auth/auth_event.dart';

class FakeAuthRepository implements AuthRepository {
  bool authenticated = false;
  UserEntity? currentUser;

  @override
  Future<bool> isAuthenticated() async => authenticated;

  @override
  Future<UserEntity?> getCurrentUser() async => currentUser;

  @override
  Future<UserEntity> login({required String email, required String password}) async {
    authenticated = true;
    return const UserEntity(id: '1', email: 'test@nexora.ai', username: 'tester');
  }

  @override
  Future<UserEntity> register({required String email, required String username, required String password}) async {
    authenticated = true;
    return const UserEntity(id: '1', email: 'test@nexora.ai', username: 'tester');
  }

  @override
  Future<void> logout() async {
    authenticated = false;
    currentUser = null;
  }

  @override
  Future<void> forgotPassword(String email) async {}

  @override
  Future<void> resetPassword({required String token, required String newPassword}) async {}
}

class FakeSecureStorageService implements SecureStorageService {
  String? token;

  @override
  Future<String?> getAccessToken() async => token;

  @override
  Future<void> clearAuth() async {
    token = null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('AppRouter Authentication Redirection', () {
    test('Router creates successfully with authBloc and storage service', () async {
      final fakeRepo = FakeAuthRepository()..authenticated = false;
      final authBloc = AuthBloc(fakeRepo)..add(AuthCheckRequested());
      final fakeStorage = FakeSecureStorageService()..token = null;

      final appRouter = AppRouter(fakeStorage, authBloc);

      expect(appRouter.router, isNotNull);

      appRouter.dispose();
      await authBloc.close();
    });
  });
}
