import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/common/utils/logger.dart';

import '../../domain/repositories/registration_signalr_repository.dart';

part 'registration_signalr_event.dart';
part 'registration_signalr_state.dart';

class RegistrationSignalRBloc extends Bloc<RegistrationSignalREvent, RegistrationSignalRState> {
  final RegistrationSignalRRepository _repository;
  late StreamSubscription<String> _streamSubscription;

  RegistrationSignalRBloc(this._repository) : super(RegistrationSignalRInitial()) {
    on<RegistrationSignalRStarted>((event, emit) async {
      await _repository.initConnection(); // gọi connect() ở đây nếu cần
    });
    
    on<RegistrationSignalRUpdated>(_handlerRegistrationSignalRUpdated);

    _streamSubscription = _repository.response().listen((data) {
      logger.e('Received data from SignalR: $data');
    });

  }

  void _handlerRegistrationSignalRUpdated(RegistrationSignalRUpdated event, Emitter<RegistrationSignalRState> emit) {
    // Handle the event and emit new states
    if (event.status == 'SUCCESS') {
      logger.d('Registration successful for course section: ${event.courseId}');
    } else {
      emit(RegistrationSignalRFailure('Failed to register for course section'));
    }
  }
}