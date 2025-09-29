part of "noti_bloc.dart";

sealed class NotiEvent extends Equatable {}

class LoadNotiEvent extends NotiEvent {
  final String authToken;
  final String idUos;

  LoadNotiEvent({ required this.authToken, required this.idUos});

  @override
  List<Object?> get props => [authToken];
}

class AddNotiEvent extends NotiEvent {
  final NotiModel newNoti;
  final String idUos;
  final String subjectName;
  final String authToken;

  AddNotiEvent(this.newNoti, this.idUos, this.subjectName, this.authToken);

  @override
  List<Object?> get props => [newNoti, idUos, authToken];
}

class DeleteNotiEvent extends NotiEvent {
  final String idNotification;
  final String idUos;
  final String authToken;

  DeleteNotiEvent(this.idNotification, this.idUos, this.authToken);

  @override
  List<Object?> get props => [idNotification, idUos, authToken];
}