import 'package:e_dut/features/schedule/data/model/unit_of_study/uos_students_absent_model.dart';
import 'package:equatable/equatable.dart';

class UosAbsentState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UosAbsentInitial extends UosAbsentState {}

class UosAbsentLoading extends UosAbsentState {}

// class UosCheckIsAttendanceDateLoading extends UosAbsentState {}

// class UosTakeAttendanceLoading extends UosAbsentState {}

// class UosDeleteAttendanceHistoryLoading extends UosAbsentState {}

class UosAbsentError extends UosAbsentState {
  final String message;
  UosAbsentError({required this.message});
  @override
  List<Object?> get props => [message];
}

class UosAbsentLoaded extends UosAbsentState {
  final UosStudentsAbsentModel listStudentAbsent;
  UosAbsentLoaded({required this.listStudentAbsent});
}

class UosCheckIsAttendanceDateLoaded extends UosAbsentState {
  final bool isAttendanceDate;
  UosCheckIsAttendanceDateLoaded({required this.isAttendanceDate});
}

class UosCheckIsAttendanceDateValidLoaded extends UosAbsentState {
  final bool isAttendanceDateValid;
  UosCheckIsAttendanceDateValidLoaded({required this.isAttendanceDateValid});
}

class UosTakeAttendanceLoaded extends UosAbsentState {
  final bool isSuccess;
  UosTakeAttendanceLoaded({required this.isSuccess});
}

class UosDeleteAttendanceHistoryLoaded extends UosAbsentState {
  final bool isSuccess;
  UosDeleteAttendanceHistoryLoaded({required this.isSuccess});
}
