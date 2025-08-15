part of 'grade_bloc.dart';

enum GradeStatus { initial, loading, success, failure }

class GradeState extends Equatable {
  final GradeStatus status;
  final List<Grade> grades;
  final String errorMessage;

  const GradeState({
    this.status = GradeStatus.initial,
    this.grades = const <Grade>[],
    this.errorMessage = "",
  });

  GradeState copyWith({
    GradeStatus Function()? status,
    List<Grade> Function()? grades,
    String Function()? errorMessage,
  }) {
    return GradeState(
      status: status != null ? status() : this.status,
      grades: grades != null ? grades() : this.grades,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    grades,
    errorMessage,
  ];
}