part of 'user_info_bloc.dart';

class UserInfoState extends Equatable {
  @override
  List<Object?> get props => throw UnimplementedError();
}

class UserInfoInitial extends UserInfoState {}

class UserInfoLoading extends UserInfoState {}

class UserInfoError extends UserInfoState {
  final String message;
  UserInfoError(this.message);

  @override
  List<Object?> get props => [message];
}

class UserInfoLoaded extends UserInfoState {
  final UserInfoModel userInfo;

  UserInfoLoaded(this.userInfo);
}
