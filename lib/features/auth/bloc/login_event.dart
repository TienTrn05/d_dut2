part of 'login_bloc.dart';

sealed class LoginEvent extends Equatable {}

class LoginUsernameChanged extends LoginEvent {
  final String? username;

  LoginUsernameChanged({this.username});

  @override
  List<Object?> get props => [username];
}

class LoginPasswordChanged extends LoginEvent {
  final String? password;

  LoginPasswordChanged({this.password});

  @override
  List<Object?> get props => [password];
}

class LoginShowPasswordChanged extends LoginEvent {
  final bool? isShowPassword;

  LoginShowPasswordChanged({this.isShowPassword});

  @override
  List<Object?> get props => [isShowPassword];
}

class LoginRememberMeChanged extends LoginEvent {
  final bool? isRememberMe;

  LoginRememberMeChanged({this.isRememberMe});

  @override
  List<Object?> get props => [isRememberMe];
}