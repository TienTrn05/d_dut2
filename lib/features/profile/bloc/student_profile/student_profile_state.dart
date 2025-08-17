part of 'student_profile_bloc.dart';

enum StudentProfileStatus { initial, loading, success, failure }

class StudentProfileState extends Equatable {
  final StudentProfileStatus studentProfileStatus;
  final StudentProfileModel? profile;
  final String errorMessage;

  const StudentProfileState(
      {this.studentProfileStatus = StudentProfileStatus.initial,
      this.profile,
      this.errorMessage = ''});

  StudentProfileState copyWith({
    StudentProfileStatus Function()? studentProfileStatus,
    StudentProfileModel? Function()? profile,
    String Function()? errorMessage,
  }) {
    return StudentProfileState(
      studentProfileStatus: studentProfileStatus != null
          ? studentProfileStatus()
          : this.studentProfileStatus,
      profile: profile != null ? profile() : this.profile,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    studentProfileStatus,
    profile,
    errorMessage
  ];
}
