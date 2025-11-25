part of 'export_absent_bloc.dart';

class ExportAbsentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ExportAbsentSummary extends ExportAbsentEvent {
  final String idUos;
  final String authToken;

  ExportAbsentSummary({required this.idUos, required this.authToken});
}
