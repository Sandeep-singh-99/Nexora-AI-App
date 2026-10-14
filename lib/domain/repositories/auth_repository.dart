import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login({required String email, required String password});
  Future<UserEntity> register({required String email, required String username, required String password});
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
  Future<void> forgotPassword(String email);
  Future<void> resetPassword({required String token, required String newPassword});
  Future<bool> isAuthenticated();
}
