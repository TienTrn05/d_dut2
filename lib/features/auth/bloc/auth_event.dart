part of   'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

// Sự kiện yêu cầu đăng nhập
class MicrosoftSignInRequested extends AuthEvent {}

class AuthLogoutRequested extends AuthEvent {}

class FetchUserProfile extends AuthEvent {
  final String accessToken; // Nhận access token từ Microsoft

  FetchUserProfile(this.accessToken);

  @override
  List<Object> get props => [accessToken];
}