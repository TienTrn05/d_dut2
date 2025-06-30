part of 'user_info_bloc.dart';

class UserInfoEvent extends Equatable {
  @override
  List<Object?> get props => throw UnimplementedError();
}

class LoadUserInfo extends UserInfoEvent {
  final String token;

  LoadUserInfo({required this.token});
}
