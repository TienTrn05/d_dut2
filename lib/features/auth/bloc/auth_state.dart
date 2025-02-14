part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  @override
  List<Object> get props => [];
}

// Trạng thái ban đầu
class AuthInitial extends AuthState {}

// Trạng thái đang đăng nhập
class AuthLoading extends AuthState {}

// Trạng thái đăng nhập thành công
class AuthAuthenticated extends AuthState {
  final String accessToken;
  AuthAuthenticated(this.accessToken);

  @override
  List<Object> get props => [accessToken];
}

class AuthUserFetched extends AuthState {
  final Map<String, dynamic> userData;

  AuthUserFetched(this.userData);

  @override
  List<Object> get props => [userData];
}

// Trạng thái lỗi đăng nhập
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);

  @override
  List<Object> get props => [message];
}
