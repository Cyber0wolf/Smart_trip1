import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

import 'auth_event.dart';
import 'auth_state.dart';
import '../data/auth_api.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthApi authApi;
  final ApiClient apiClient;
  final TokenStorage tokenStorage = TokenStorage();

  AuthBloc(this.authApi, this.apiClient) : super(AuthInitial()) {
    on<LoginRequested>(_onLogin);
    on<SignupRequested>(_onSignup);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onLogin(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final data = await authApi.login(
        email: event.email,
        password: event.password,
      );

      final token = data['access'];
      await tokenStorage.saveToken(token);
      apiClient.setToken(token);

      emit(AuthSuccess());
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? 'Invalid credentials';
      emit(AuthFailure(msg));
    } catch (_) {
      emit(AuthFailure('Login failed'));
    }
  }

  Future<void> _onSignup(
    SignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await authApi.signup(
        email: event.email,
        password: event.password,
      );
      final data = await authApi.login(
        email: event.email,
        password: event.password,
      );
      final token = data['access'];
      await tokenStorage.saveToken(token);
      apiClient.setToken(token);
      emit(AuthSuccess());
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? 'Signup failed';
      emit(AuthFailure(msg));
    } catch (_) {
      emit(AuthFailure('Signup failed'));
    }
  }

  Future<void> _onLogout(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await tokenStorage.clear();
    emit(AuthInitial());
  }
}
