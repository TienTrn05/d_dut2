part of 'registration_signalr_bloc.dart';

class RegistrationSignalRState extends Equatable {
  const RegistrationSignalRState();

  @override
  List<Object> get props => [];
}

class RegistrationSignalRInitial extends RegistrationSignalRState {
  @override
  List<Object> get props => [];
}

class RegistrationSignalRFailure extends RegistrationSignalRState {
  final String error;

  const RegistrationSignalRFailure(this.error);

  @override
  List<Object> get props => [error];
}