part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  @override
  List<Object> get props => [];
}

// Trạng thái ban đầu
class AuthInitial extends AuthState {}

// Trạng thái đăng nhập thành công
class AuthUserAuthenticated extends AuthState {
  final String accessToken;
  final UserModel userData;

  AuthUserAuthenticated(this.accessToken, this.userData);

  @override
  List<Object> get props => [accessToken,userData];
}

class AuthLogoutSuccess extends AuthState {}

// Trạng thái lỗi đăng nhập
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);

  @override
  List<Object> get props => [message];
}

class AuthLoading extends AuthState {}

class AuthHandlerFinished extends AuthState {}