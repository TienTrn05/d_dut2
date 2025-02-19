import 'dart:convert';

import 'package:e_dut/features/auth/domain/repository/auth_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';

import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:aad_oauth/model/failure.dart';
import 'package:aad_oauth/model/token.dart';

import '../../../common/utils/app_environment.dart';
import '../../../core/data/local/storage.dart';
import '../../../features/auth/data/model/user_model.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GlobalKey<NavigatorState> navigatorKey;
  late final AadOAuth _microsoftSignIn;
  final AuthRepository _authRepository;
  final Dio _dio = Dio();

  AuthBloc(this.navigatorKey, this._authRepository)
      : super(AuthInitial()) {
    _microsoftSignIn = AadOAuth(Config(
      tenant: AppEnvironment.tenantId,
      clientId: AppEnvironment.clientId,
      redirectUri: AppEnvironment.redirectUri,
      responseType: "code",
      scope: "User.Read",
      loader: const Center(child: CircularProgressIndicator()),
      navigatorKey: navigatorKey, // Truyền navigatorKey
    ));

    on<MicrosoftSignInRequested>(_onMicrosoftSignIn);
    on<AuthLoginRequested>(_onLogin);
    on<FetchUserProfile>(_onFetchUserProfile);
    on<AuthLogoutRequested>(_onLogout);
  }

  Future<void> _onMicrosoftSignIn(
      MicrosoftSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    var result = await _microsoftSignIn.login();
    result.fold(
      (Failure failure) {
        emit(AuthError(failure.toString()));
      },
      (Token token) async {
        if (token.accessToken == null) {
          emit(AuthError("Access token is missing"));
          return;
        }

        emit(AuthAuthenticated(token.accessToken!));
        add(FetchUserProfile(token.accessToken!));
      },
    );
  }

  Future<void> _onLogin(
      AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final data = await _authRepository.signIn(event.username, event.password);

      await Storage.setAccessToken(data["accessToken"]);

      emit(AuthAuthenticated(data["accessToken"]));
      emit(AuthUserFetched(data["user"]));

      await Storage.setUser(data["user"]);
    } catch (e) {
      emit(AuthError("Failed to login: $e"));
    }
  }

  Future<void> _onFetchUserProfile(
      FetchUserProfile event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());

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
        final UserModel userData = UserModel.fromJson(jsonDecode(response.data));
        emit(AuthUserFetched(userData));
      } else if (response.data is Map<String, dynamic>) {
        final UserModel userData = UserModel.fromJson(response.data);
        emit(AuthUserFetched(userData));
      } else {
        emit(AuthError("Unexpected response format"));
      }
    } catch (e) {
      emit(AuthError("Failed to fetch user data: $e"));
    }
  }

  Future<void> _onLogout(
      AuthLogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    await _microsoftSignIn.logout();
    emit(AuthLogoutSuccess());
  }
}
