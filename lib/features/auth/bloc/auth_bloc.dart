import 'package:e_dut/core/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:aad_oauth/model/failure.dart';
import 'package:aad_oauth/model/token.dart';

import '../../../common/utils/app_environment.dart';
import '../../../common/utils/logger.dart';
import '../../../common/widgets/loading/cube_grid_loading.dart';
import '../../../core/data/local/storage.dart';
import '../../../features/auth/data/model/user_model.dart';
import '../../../features/auth/domain/repository/auth_repo.dart';
import '../../../features/notification/domain/repositories/notification_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GlobalKey<NavigatorState> navigatorKey;
  final AuthRepository _authRepository;
  final NotificationRepository _notificationRepository;

  AuthBloc(
      this.navigatorKey, this._authRepository, this._notificationRepository)
      : super(AuthInitial()) {
    on<AuthInitRequested>(_onInitUser);
    on<MicrosoftSignInRequested>(_onMicrosoftSignIn);
    on<AuthLoginRequested>(_onLogin);
    on<AuthLogoutRequested>(_onLogout);
  }

  AadOAuth _microsoftSignInSetup(String? savedEmail) {
    return AadOAuth(Config(
      tenant: AppEnvironment.tenantId,
      clientId: AppEnvironment.clientId,
      redirectUri: AppEnvironment.redirectUri,
      responseType: "code",
      scope: "User.Read",
      loginHint: savedEmail ?? "",
      loader: const Center(
          child: CubeGridLoading(
        backgroundColor: Color(0xFF2A74BD),
      )),
      navigatorKey: navigatorKey, // Truyền navigatorKey
    ));
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
    String savedEmail = Storage.hintEmail ?? "";
    AadOAuth microsoftSignIn = _microsoftSignInSetup(savedEmail);

    var result = await microsoftSignIn.login();

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

        try {
          final data =
              await _authRepository.getProfileWithMicrosoft(token.accessToken!);

          await Storage.setAccessToken(data["accessToken"]);
          await Storage.setUser(data["user"]);

          if (event.FCMToken.isNotEmpty) {
            try {
              await _notificationRepository.registerFCMToken(
                  data["accessToken"], event.FCMToken);
            } catch (e) {
              logger.e("Failed to register FCM token: $e");
            }
          }

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
      emit(AuthLoading());
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
    await _microsoftSignInSetup(null).logout();
    await Storage.setAccessToken(null);
    await Storage.setUser(null);
    await Storage.setHintEmail(event.email);
    await Storage.setExamNotification(true);

    emit(AuthLogoutSuccess());
    emit(AuthHandlerFinished());
  }
}
