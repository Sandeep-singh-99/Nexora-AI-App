import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/user_model.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthForgotPasswordRequested>(_onAuthForgotPasswordRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final isAuth = await _authRepository.isAuthenticated();
      if (!isAuth) {
        emit(Unauthenticated());
        return;
      }
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        final stillAuth = await _authRepository.isAuthenticated();
        if (stillAuth) {
          emit(const Authenticated(UserModel(id: 'me', email: 'user@nexora.ai', username: 'User')));
        } else {
          emit(Unauthenticated());
        }
      }
    } catch (_) {
      final stillAuth = await _authRepository.isAuthenticated();
      if (stillAuth) {
        emit(const Authenticated(UserModel(id: 'me', email: 'user@nexora.ai', username: 'User')));
      } else {
        emit(Unauthenticated());
      }
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.login(
        email: event.email,
        password: event.password,
      );
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthFailureState(e.toString().replaceAll('Exception: ', '').replaceAll('AuthException: ', '')));
    }
  }

  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.register(
        email: event.email,
        username: event.username,
        password: event.password,
      );
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthFailureState(e.toString().replaceAll('Exception: ', '').replaceAll('AuthException: ', '')));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    emit(Unauthenticated());
  }

  Future<void> _onAuthForgotPasswordRequested(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.forgotPassword(event.email);
      emit(PasswordResetEmailSent(event.email));
    } catch (e) {
      emit(AuthFailureState(e.toString()));
    }
  }
}
