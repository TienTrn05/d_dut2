part of 'homeroom_bloc.dart';

class HomeroomState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HomeroomInitial extends HomeroomState {}

class HomeroomLoading extends HomeroomState {}

class HomeroomError extends HomeroomState {
  final String message;
  HomeroomError(this.message);
  @override
  List<Object?> get props => [message];
}

class HomeroomLoaded extends HomeroomState {
  final List<StudentModel> students;

  HomeroomLoaded({required this.students});
}
