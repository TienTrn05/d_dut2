part of "noti_bloc.dart";

sealed class NotiEvent extends Equatable {}

class LoadNotiEvent extends NotiEvent {
  @override
  List<Object?> get props => [];
}

class AddNotiEvent extends NotiEvent {
  final NotiModel newNoti;
  final String idUos;
  final String authToken;

  AddNotiEvent(this.newNoti, this.idUos, this.authToken);

  @override
  List<Object?> get props => [newNoti, idUos, authToken];
}