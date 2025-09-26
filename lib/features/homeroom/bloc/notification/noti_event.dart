part of "noti_bloc.dart";

sealed class NotiEvent extends Equatable {}

class LoadNotiEvent extends NotiEvent {
  final String authToken;
  final String classId;

  LoadNotiEvent({ required this.authToken, required this.classId});

  @override
  List<Object?> get props => [authToken];
}

class AddNotiEvent extends NotiEvent {
  final NotiModel newNoti;
  final String classId;
  final String className;
  final String authToken;

  AddNotiEvent(this.newNoti, this.classId, this.className, this.authToken);

  @override
  List<Object?> get props => [newNoti, classId, className, authToken];
}

class DeleteNotiEvent extends NotiEvent {
  final String idNotification;
  final String classId;
  final String authToken;

  DeleteNotiEvent(this.idNotification, this.classId, this.authToken);

  @override
  List<Object?> get props => [idNotification, classId, authToken];
}