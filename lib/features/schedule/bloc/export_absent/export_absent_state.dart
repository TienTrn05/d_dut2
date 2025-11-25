part of 'export_absent_bloc.dart';

class ExportAbsentState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ExportAbsentInitial extends ExportAbsentState {}

class ExportAbsentLoading extends ExportAbsentState {}

class ExportAbsentSuccess extends ExportAbsentState {}

class ExportAbsentError extends ExportAbsentState {
  final String message;
  ExportAbsentError(this.message);
  @override
  List<Object?> get props => [message];
}
