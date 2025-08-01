part of 'timetable_bloc.dart';

class TimetableEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadListSemesters extends TimetableEvent {
  final bool isTeacher;
  final String authToken;

  LoadListSemesters({required this.isTeacher, required this.authToken});
}

class LoadListUOSBySemester extends TimetableEvent {
  final String idSemester;
  final int selectedIndex;
  final bool isTeacher;
  final String authToken;

  LoadListUOSBySemester(
      {required this.idSemester,
      required this.selectedIndex,
      required this.isTeacher,
      required this.authToken});

  @override
  List<Object?> get props => [
        idSemester,
        selectedIndex
      ]; //2 instance LoadListUOSBySemester được xem là bằng nhau nếu idSemester và selectedIndex giống nhau
}
