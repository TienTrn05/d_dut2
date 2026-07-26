import 'package:e_dut/common/widgets/loading/microsoft_loading.dart';
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
import '../../../features/notification/domain/repositories/notification_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GlobalKey<NavigatorState> navigatorKey;
  final AuthRepository authRepository;
  final NotificationRepository notificationRepository;

  final UserModel? userData;
  final String? accessToken;

  AuthBloc({
    required this.navigatorKey,
    required this.authRepository,
    required this.notificationRepository,
    this.userData,
    this.accessToken,
  }) : super(
         (userData != null && accessToken != null)
             ? AuthUserAuthenticated(accessToken, userData)
             : AuthHandlerFinished(),
       ) {
    on<MicrosoftSignInRequested>(_onMicrosoftSignIn);
    on<AuthLoginRequested>(_onLogin);
    on<AuthLogoutRequested>(_onLogout);
  }

  AadOAuth _microsoftSignInSetup(String? savedEmail) {
    return AadOAuth(
      Config(
        tenant: AppEnvironment.tenantId,
        clientId: AppEnvironment.clientId,
        redirectUri: AppEnvironment.redirectUri,
        responseType: "code",
        scope: "User.Read",
        loginHint: savedEmail ?? "",
        loader: MicrosoftLoading(),
        navigatorKey: navigatorKey, // Truyền navigatorKey
      ),
    );
  }

  Future<void> _onMicrosoftSignIn(
    MicrosoftSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
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
          final data = await authRepository.getProfileWithMicrosoft(
            token.accessToken!,
          );

          await Storage.setAccessToken(data["accessToken"]);
          await Storage.setUser(data["user"]);

          if (event.FCMToken.isNotEmpty) {
            try {
              await notificationRepository.registerFCMToken(
                data["accessToken"],
                event.FCMToken,
              );
            } catch (e) {
              logger.e("Failed to register FCM token: $e");
            }
          }

          emit(AuthUserAuthenticated(data["accessToken"], data["user"]));
        } catch (e) {
          logger.e("Failed to login: $e");
          emit(AuthError("Đăng nhập thất bại. Vui lòng thử lại sau."));
        }
      },
    );
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      final data = await authRepository.signIn(event.username, event.password);

      await Storage.setAccessToken(data["accessToken"]);

      emit(AuthUserAuthenticated(data["accessToken"], data["user"]));

      await Storage.setAccessToken(data["accessToken"]);
      await Storage.setUser(data["user"]);
    } catch (e) {
      logger.e("Failed to login: $e");
      emit(AuthError("Đăng nhập thất bại. Vui lòng thử lại sau."));
    }
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _microsoftSignInSetup(null).logout();
    await Storage.setAccessToken(null);
    await Storage.setUser(null);
    if (event.email.isNotEmpty) {
      await Storage.setHintEmail(event.email);
    }
    await Storage.setExamNotification(true);

    emit(AuthLogoutSuccess());
    emit(AuthHandlerFinished());
  }
}
