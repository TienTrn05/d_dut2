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

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GlobalKey<NavigatorState> navigatorKey;
  late final AadOAuth _microsoftSignIn;
  final Dio _dio = Dio();

  AuthBloc(this.navigatorKey)
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
      final response = await _dio.post(
        "https://sso.dev.dut.udn.vn/login",
        data: {
          "username": event.username,
          "password": event.password,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        final String accessToken = data["accessToken"];

        emit(AuthAuthenticated(accessToken));
        emit(AuthUserFetched(data["user"]));
      } else {
        emit(AuthError("Failed to login: ${response.data["message"]}"));
      }
    } catch (e) {
      emit(AuthError("Failed to login: $e"));
    }
  }

  Future<void> _onFetchUserProfile(
      FetchUserProfile event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());

      final response = await _dio.get(
        "https://sso.dev.dut.udn.vn/profile/me",
        options: Options(
          headers: {
            "Authorization": "Bearer ${event.accessToken}",
          },
        ),
      );

      if (response.data is String) {
        // Chuyển đổi String thành JSON
        final Map<String, dynamic> userData = jsonDecode(response.data);
        emit(AuthUserFetched(userData));
      } else if (response.data is Map<String, dynamic>) {
        emit(AuthUserFetched(response.data));
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
