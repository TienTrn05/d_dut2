part of 'teacher_profile_bloc.dart';

class TeacherProfileEvent extends Equatable {
  const TeacherProfileEvent();

  @override
  List<Object> get props => [];
}

class LoadTeacherProfile extends TeacherProfileEvent {
  final String token;

  const LoadTeacherProfile(this.token);

  @override
  List<Object> get props => [token];
}