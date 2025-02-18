part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class MicrosoftSignInRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String username;
  final String password;

  AuthLoginRequested(this.username, this.password);
}

class AuthLogoutRequested extends AuthEvent {}

class FetchUserProfile extends AuthEvent {
  final String accessToken; // Get access token from Microsoft

  FetchUserProfile(this.accessToken);

  @override
  List<Object> get props => [accessToken];
}