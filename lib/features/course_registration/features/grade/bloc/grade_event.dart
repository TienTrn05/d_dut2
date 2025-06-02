part of 'grade_bloc.dart';

sealed class GradeEvent extends Equatable {
  const GradeEvent();
  @override
  List<Object> get props => [];
}

class GradesSubscriptionRequested extends GradeEvent {
  final String token;

  const GradesSubscriptionRequested({
    required this.token,
  });
  
  @override
  List<Object> get props => [token];
}