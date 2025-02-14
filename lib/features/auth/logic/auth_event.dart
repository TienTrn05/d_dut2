import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

// Sự kiện yêu cầu đăng nhập
class MicrosoftSignInRequested extends AuthEvent {}
