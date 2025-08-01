import 'package:equatable/equatable.dart';

class ListAbsentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadListAbsent extends ListAbsentEvent {
  final String idUos;
  final String? idStudent;
  final String authToken;

  LoadListAbsent({
    required this.idUos,
    this.idStudent,
    required this.authToken,
  });
}
