import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

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
  final String? savedEmail = Storage.user?.mail;

  AuthBloc(this.navigatorKey, this._authRepository) : super(AuthInitial()) {
    _microsoftSignIn = AadOAuth(Config(
      tenant: AppEnvironment.tenantId,
      clientId: AppEnvironment.clientId,
      redirectUri: AppEnvironment.redirectUri,
      responseType: "code",
      scope: "User.Read",
      loginHint: savedEmail ?? "102210239@sv1.dut.udn.vn",
      loader: const Center(child: CircularProgressIndicator()),
      navigatorKey: navigatorKey, // Truyền navigatorKey
    ));

    on<AuthInitRequested>(_onInitUser);
    on<MicrosoftSignInRequested>(_onMicrosoftSignIn);
    on<AuthLoginRequested>(_onLogin);
    on<AuthLogoutRequested>(_onLogout);
  }

  Future<void> _onInitUser(
      AuthInitRequested event, Emitter<AuthState> emit) async {
    try {
      final String? token = await Storage.accessToken;
      final UserModel? user = Storage.user;

      if (token != null && user != null) {
        emit(AuthUserAuthenticated(token, user));
      } else {
        emit(AuthHandlerFinished());
      }
    } catch (e) {
      logger.e("Failed to load user from storage: $e");
      emit(AuthError("Không thể lấy thông tin người dùng."));
    }
  }

  Future<void> _onMicrosoftSignIn(
      MicrosoftSignInRequested event, Emitter<AuthState> emit) async {
    var result = await _microsoftSignIn.login();

    await result.fold(
      (Failure failure) async {
        logger.e("Failed to login: $failure");
      },
      (Token token) async {
        emit(AuthLoading());
        if (token.accessToken == null) {
          logger.e("Access token is missing");
          emit(AuthError("Đăng nhập thất bại. Vui lòng thử lại sau."));
          return;
        }

        try{
          final data =
              await _authRepository.getProfileWithMicrosoft(token.accessToken!);

          await Storage.setAccessToken(data["accessToken"]);
          await Storage.setUser(data["user"]);

          emit(AuthUserAuthenticated(
            data["accessToken"],
            data["user"],
          ));
        } catch (e) {
          logger.e("Failed to login: $e");
          emit(AuthError("Đăng nhập thất bại. Vui lòng thử lại sau."));
        }
      },
    );
  }

  Future<void> _onLogin(
      AuthLoginRequested event, Emitter<AuthState> emit) async {
    try {
      final data = await _authRepository.signIn(event.username, event.password);

      await Storage.setAccessToken(data["accessToken"]);

      emit(AuthUserAuthenticated(
        data["accessToken"],
        data["user"],
      ));

      await Storage.setAccessToken(data["accessToken"]);
      await Storage.setUser(data["user"]);
    } catch (e) {
      logger.e("Failed to login: $e");
      emit(AuthError("Đăng nhập thất bại. Vui lòng thử lại sau."));
    }
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
