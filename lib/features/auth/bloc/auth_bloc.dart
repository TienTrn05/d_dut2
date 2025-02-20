import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';

import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:aad_oauth/model/failure.dart';
import 'package:aad_oauth/model/token.dart';

import '../../../common/utils/app_environment.dart';
import '../../../common/utils/logger.dart';
import '../../../core/data/local/storage.dart';
import '../../../features/auth/data/model/user_model.dart';
import '../../../features/auth/domain/repository/auth_repo.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GlobalKey<NavigatorState> navigatorKey;
  late final AadOAuth _microsoftSignIn;
  final AuthRepository _authRepository;
  final Dio _dio = Dio();

  AuthBloc(this.navigatorKey, this._authRepository) : super(AuthInitial()) {
    _microsoftSignIn = AadOAuth(Config(
      tenant: AppEnvironment.tenantId,
      clientId: AppEnvironment.clientId,
      redirectUri: AppEnvironment.redirectUri,
      responseType: "code",
      scope: "User.Read",
      loader: const Center(child: CircularProgressIndicator()),
      navigatorKey: navigatorKey, // Truyền navigatorKey
    ));

    on<AuthInitRequested>(_onInitUser);
    on<MicrosoftSignInRequested>(_onMicrosoftSignIn);
    on<AuthLoginRequested>(_onLogin);
    on<FetchUserProfile>(_onFetchUserProfile);
    on<AuthLogoutRequested>(_onLogout);
  }

  Future<void> _onInitUser(
      AuthInitRequested event, Emitter<AuthState> emit) async {
    try {
      final String? token = await Storage.accessToken;
      final UserModel? user = Storage.user;

      if (token != null && user != null) {
        emit(AuthAuthenticated(token));
        emit(AuthUserFetched(user));
      }
    } catch (e) {
      logger.e("Failed to load user from storage: $e");
      emit(AuthError("Không thể lấy thông tin người dùng."));
    }
  }

  Future<void> _onMicrosoftSignIn(
      MicrosoftSignInRequested event, Emitter<AuthState> emit) async {
    var result = await _microsoftSignIn.login();
    result.fold(
      (Failure failure) {
        logger.e("Failed to login: $failure");
      },
      (Token token) async {
        if (token.accessToken == null) {
          logger.e("Access token is missing");
          emit(AuthError("Đăng nhập thất bại. Vui lòng thử lại sau."));
          return;
        }

        emit(AuthAuthenticated(token.accessToken!));
        add(FetchUserProfile(token.accessToken!));
      },
    );
  }

  Future<void> _onLogin(
      AuthLoginRequested event, Emitter<AuthState> emit) async {
    try {
      final data = await _authRepository.signIn(event.username, event.password);

      await Storage.setAccessToken(data["accessToken"]);

      emit(AuthAuthenticated(data["accessToken"]));
      emit(AuthUserFetched(data["user"]));

      await Storage.setAccessToken(data["accessToken"]);
      await Storage.setUser(data["user"]);
    } catch (e) {
      logger.e("Failed to login: $e");
      emit(AuthError("Đăng nhập thất bại. Vui lòng thử lại sau."));
    }
  }

  Future<void> _onFetchUserProfile(
      FetchUserProfile event, Emitter<AuthState> emit) async {
    try {
      final response = await _dio.get(
        "https://sso.dev.dut.udn.vn/microsoft/me",
        options: Options(
          headers: {
            "Authorization": "Bearer ${event.accessToken}",
          },
        ),
      );

      if (response.data is String) {
        // Chuyển đổi String thành JSON
        final UserModel userData =
            UserModel.fromJson(jsonDecode(response.data));
        emit(AuthUserFetched(userData));
      } else if (response.data is Map<String, dynamic>) {
        final UserModel userData = UserModel.fromJson(response.data);
        emit(AuthUserFetched(userData));
      } else {
        emit(AuthError("Failed to fetch user data"));
      }
    } catch (e) {
      logger.e("Failed to fetch user data: $e");
      emit(AuthError(
          "Đã xảy ra lỗi khi lấy thông tin người dùng. Vui lòng thử lại sau."));
    }
    emit(AuthHandlerFinished());
  }

  Future<void> _onLogout(
      AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _microsoftSignIn.logout();
    await Storage.setAccessToken(null);
    await Storage.setUser(null);
    emit(AuthLogoutSuccess());
    emit(AuthHandlerFinished());
  }
}
