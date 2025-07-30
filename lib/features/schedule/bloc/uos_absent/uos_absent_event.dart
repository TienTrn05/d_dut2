import 'package:equatable/equatable.dart';

class UosAbsentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadStudentsAbsent extends UosAbsentEvent {
  final String idUos;
  final int pageNumber;
  final String? keyword;
  final DateTime? absenceDate;

  LoadStudentsAbsent({
    required this.idUos,
    required this.pageNumber,
    this.keyword,
    this.absenceDate,
  });
}

class LoadIsAttendanceDate extends UosAbsentEvent {
  final String idUos;
  final DateTime? attendanceDate;

  LoadIsAttendanceDate({
    required this.idUos,
    this.attendanceDate,
  });
}

class TakeAttendance extends UosAbsentEvent {
  final String idUnitOfStudy;
  final DateTime absenceDate;
  final List<String> idStudentsAbsent;

  TakeAttendance({
    required this.idUnitOfStudy,
    required this.absenceDate,
    required this.idStudentsAbsent,
  });
}

class DeleteAttendanceHistory extends UosAbsentEvent {
  final String idUos;
  final DateTime attendanceDate;

  DeleteAttendanceHistory({
    required this.idUos,
    required this.attendanceDate,
  });
}
