part of 'timetable_bloc.dart';

class TimetableState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TimetableInitial extends TimetableState {}

class TimetableLoading extends TimetableState {}

class TimetableError extends TimetableState {
  final String message;
  TimetableError(this.message);
  @override
  List<Object?> get props => [message];
}

class SemesterListLoaded extends TimetableState {
  final List<SemesterModel> semesters;
  SemesterListLoaded(this.semesters);
  @override
  List<Object?> get props => [semesters];
}
