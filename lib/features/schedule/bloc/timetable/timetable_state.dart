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

// class SemesterListLoaded extends TimetableState {
//   final List<SemesterModel> semesters;
//   SemesterListLoaded(this.semesters);
//   @override
//   List<Object?> get props => [semesters];
// }

// class UOSBySemesterLoaded extends TimetableState {
//   final List<UosItemModel> listUOS;
//   UOSBySemesterLoaded(this.listUOS);
//   @override
//   List<Object?> get props => [listUOS];
// }

class TimetableDataLoaded extends TimetableState {
  final List<SemesterModel> semesters;
  final List<UosItemModel> listUOS;
  final int selectedIndex;

  TimetableDataLoaded(this.semesters, this.listUOS, this.selectedIndex);

  @override
  List<Object?> get props => [semesters, listUOS, selectedIndex];
}
