part of 'timetable_bloc.dart';

class TimetableEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadListSemesters extends TimetableEvent {
  final bool isTeacher;

  LoadListSemesters({required this.isTeacher});
}

class LoadListUOSBySemester extends TimetableEvent {
  final String idSemester;
  final int selectedIndex;
  final bool isTeacher;

  LoadListUOSBySemester(
      {required this.idSemester,
      required this.selectedIndex,
      required this.isTeacher});

  @override
  List<Object?> get props => [
        idSemester,
        selectedIndex
      ]; //2 instance LoadListUOSBySemester được xem là bằng nhau nếu idSemester và selectedIndex giống nhau
}
