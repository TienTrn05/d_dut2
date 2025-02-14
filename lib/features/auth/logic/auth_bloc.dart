import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:aad_oauth/model/failure.dart';
import 'package:aad_oauth/model/token.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GlobalKey<NavigatorState> navigatorKey;
  late final AadOAuth _microsoftSignIn;

  AuthBloc(this.navigatorKey) : super(AuthInitial()) {
    _microsoftSignIn = AadOAuth(Config(
      tenant: dotenv.env['TENANT_ID']!,
      clientId: dotenv.env['CLIENT_ID']!,
      redirectUri: dotenv.env['REDIRECT_URI']!,
      responseType: "code",
      scope: "User.Read",
      loader: const Center(child: CircularProgressIndicator()),
      navigatorKey: navigatorKey, // Truyền navigatorKey
    ));

    on<MicrosoftSignInRequested>(_onMicrosoftSignIn);
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

        print('Logged in successfully: ${token.accessToken!}');
        emit(AuthAuthenticated(token.accessToken!));

        await _microsoftSignIn.logout();
      },
    );
  }
}
