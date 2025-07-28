import 'package:e_dut/features/schedule/data/model/unit_of_study/uos_students_absent_model.dart';
import 'package:equatable/equatable.dart';

class UosAbsentState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UosAbsentInitial extends UosAbsentState {}

class UosAbsentLoading extends UosAbsentState {}

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
