part of 'student_profile_bloc.dart';

class StudentProfileEvent extends Equatable {
  const StudentProfileEvent();

  @override
  List<Object> get props => [];
}

class LoadStudentProfile extends StudentProfileEvent {
  final String token;

  const LoadStudentProfile(this.token);

  @override
  List<Object> get props => [token];
}