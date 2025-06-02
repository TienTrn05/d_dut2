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

    _streamSubscription = _repository.response().listen((data) {
      logger.e('Received data from SignalR: $data');
    });
  }

  @override
  Future<void> close() async {
    logger.d('Closing RegistrationSignalRBloc');
    await _streamSubscription.cancel(); // Hủy stream listener
    await _repository.disconnect(); // Ngắt kết nối SignalR
    return super.close(); // Gọi hàm close của Bloc cha
  }
}