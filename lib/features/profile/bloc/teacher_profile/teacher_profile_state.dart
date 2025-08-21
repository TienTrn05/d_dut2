part of 'teacher_profile_bloc.dart';

enum TeacherProfileStatus { initial, loading, success, failure }

class TeacherProfileState extends Equatable {
  final TeacherProfileStatus teacherProfileStatus;
  final TeacherProfileModel? profile;
  final String errorMessage;

  const TeacherProfileState(
      {this.teacherProfileStatus = TeacherProfileStatus.initial,
      this.profile,
      this.errorMessage = ''});

  TeacherProfileState copyWith({
    TeacherProfileStatus Function()? teacherProfileStatus,
    TeacherProfileModel? Function()? profile,
    String Function()? errorMessage,
  }) {
    return TeacherProfileState(
      teacherProfileStatus: teacherProfileStatus != null
          ? teacherProfileStatus()
          : this.teacherProfileStatus,
      profile: profile != null ? profile() : this.profile,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    teacherProfileStatus,
    profile,
    errorMessage
  ];
}
