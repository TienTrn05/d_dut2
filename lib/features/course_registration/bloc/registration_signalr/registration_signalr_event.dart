part of 'registration_signalr_bloc.dart';

class RegistrationSignalREvent extends Equatable {
  const RegistrationSignalREvent();

  @override
  List<Object> get props => [];
}

class RegistrationSignalRUpdated extends RegistrationSignalREvent {
  final String courseId;
  final String status;

  const RegistrationSignalRUpdated(this.courseId, this.status);

  @override
  List<Object> get props => [courseId, status];
}

class RegistrationSignalRStarted extends RegistrationSignalREvent {
  const RegistrationSignalRStarted();

  @override
  List<Object> get props => [];
}