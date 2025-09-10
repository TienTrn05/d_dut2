part of 'homeroom_bloc.dart';

class HomeroomEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadStudentsOfHomeroom extends HomeroomEvent {
  final String token;
  final String classId;

  LoadStudentsOfHomeroom({required this.token, required this.classId});
}
