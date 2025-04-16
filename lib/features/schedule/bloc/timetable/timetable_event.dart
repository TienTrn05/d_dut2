part of 'timetable_bloc.dart';

class TimetableEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadListSemesters extends TimetableEvent {}

class LoadListUOSBySemester extends TimetableEvent {
  final String idSemester;
  final int selectedIndex;

  LoadListUOSBySemester(
      {required this.idSemester, required this.selectedIndex});

  @override
  List<Object?> get props => [
        idSemester,
        selectedIndex
      ]; //2 instance LoadListUOSBySemester được xem là bằng nhau nếu idSemester và selectedIndex giống nhau
}
