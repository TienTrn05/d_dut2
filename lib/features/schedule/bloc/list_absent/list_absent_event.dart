import 'package:equatable/equatable.dart';

class ListAbsentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadListAbsent extends ListAbsentEvent {
  final String idUos;
  final String idStudent;

  LoadListAbsent({
    required this.idUos,
    required this.idStudent,
  });
}
