import 'package:equatable/equatable.dart';

class ListAbsentState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ListAbsentInitial extends ListAbsentState {}

class ListAbsentLoading extends ListAbsentState {}

class ListAbsentError extends ListAbsentState {
  final String message;
  ListAbsentError({required this.message});
  @override
  List<Object?> get props => [message];
}

class ListAbsentLoaded extends ListAbsentState {
  final List<DateTime> listAbsentDate;
  ListAbsentLoaded({required this.listAbsentDate});
}
