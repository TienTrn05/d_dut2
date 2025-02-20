part of 'login_bloc.dart';

class LoginState extends Equatable {
  final String username;
  final String password;
  final bool isShowPassword;
  final bool isRememberMe;

  const LoginState({
    this.username = '',
    this.password = '',
    this.isShowPassword = false,
    this.isRememberMe = false,
  });

  LoginState copyWith({
    String? username,
    String? password,
    bool? isShowPassword,
    bool? isRememberMe,
  }) {
    return LoginState(
      username: username ?? this.username,
      password: password ?? this.password,
      isShowPassword: isShowPassword ?? this.isShowPassword,
      isRememberMe: isRememberMe ?? this.isRememberMe,
    );
  }

  @override
  List<Object?> get props => [username, password, isShowPassword, isRememberMe];
}