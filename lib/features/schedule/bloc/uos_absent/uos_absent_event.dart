import 'package:equatable/equatable.dart';

class UosAbsentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadStudentsAbsent extends UosAbsentEvent {
  final String idUos;
  final int pageNumber;
  final String? keyword;
  final DateTime absenceDate;
  final String authToken;

  LoadStudentsAbsent({
    required this.idUos,
    required this.pageNumber,
    this.keyword,
    required this.absenceDate,
    required this.authToken,
  });
}

class LoadIsAttendanceDate extends UosAbsentEvent {
  final String idUos;
  final DateTime? attendanceDate;
  final String authToken;

  LoadIsAttendanceDate({
    required this.idUos,
    this.attendanceDate,
    required this.authToken,
  });
}

class LoadIsAttendanceDateValid extends UosAbsentEvent {
  final String idUos;
  final DateTime? attendanceDate;
  final String authToken;

  LoadIsAttendanceDateValid({
    required this.idUos,
    this.attendanceDate,
    required this.authToken,
  });
}

class TakeAttendance extends UosAbsentEvent {
  final String idUnitOfStudy;
  final DateTime absenceDate;
  final List<String> idStudentsAbsent;
  final String authToken;

  TakeAttendance({
    required this.idUnitOfStudy,
    required this.absenceDate,
    required this.idStudentsAbsent,
    required this.authToken,
  });
}

class DeleteAttendanceHistory extends UosAbsentEvent {
  final String idUos;
  final DateTime attendanceDate;
  final String authToken;

  DeleteAttendanceHistory({
    required this.idUos,
    required this.attendanceDate,
    required this.authToken,
  });
}
