import 'dart:async';

import 'package:e_dut/common/utils/logger.dart';
import 'package:e_dut/features/queue/data/models/counter_queue_model.dart';
import 'package:e_dut/features/queue/data/models/user_ticket_model.dart';
import 'package:e_dut/features/queue/domain/repository/queue_repo.dart';
import 'package:e_dut/features/queue/helper/constant/ticket_status.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'queue_event.dart';
part 'queue_state.dart';

class QueueBloc extends Bloc<QueueEvent, QueueState> {
  final QueueRepository _repository;

  QueueBloc(this._repository) : super(const QueueState()) {
    on<LoadQueueDataEvent>(_onLoadQueueData);
    on<_TicketsLoaded>(_onTicketsLoaded);
    on<_CountersLoaded>(_onCountersLoaded);
  }

  Future<void> _onLoadQueueData(
    LoadQueueDataEvent event,
    Emitter<QueueState> emit,
  ) async {
    emit(
      state.copyWith(
        ticketsStatus: QueueStatus.loading,
        countersStatus: QueueStatus.loading,
      ),
    );
    _repository.getUserTicketsToday(event.noGuest).then((tickets) {
      tickets.sort((a, b) {
        final statusA = TicketStatus.fromInt(a.ticketStatus);
        final statusB = TicketStatus.fromInt(b.ticketStatus);

        if (statusA.isFinished != statusB.isFinished) {
          return statusA.isFinished ? 1 : -1;
        }

        return a.noTicket.compareTo(b.noTicket);
      });
      add(_TicketsLoaded(tickets));
    }, onError: (e) => add(_TicketsLoaded(const [], hasError: true)));

    _repository.getAllQueueCounter().then(
      (counters) => add(_CountersLoaded(counters)),
      onError: (e) => add(_CountersLoaded(const [], hasError: true)),
    );
  }

  void _onTicketsLoaded(_TicketsLoaded event, Emitter<QueueState> emit) {
    try {
      emit(
        state.copyWith(
          ticketsStatus:
              event.hasError ? QueueStatus.failure : QueueStatus.success,
          userTickets: event.tickets,
        ),
      );
    } catch (e) {
      logger.e("Fail to load user tickets: $e", exception: e);
    }
  }

  void _onCountersLoaded(_CountersLoaded event, Emitter<QueueState> emit) {
    try {
      emit(
        state.copyWith(
          countersStatus:
              event.hasError ? QueueStatus.failure : QueueStatus.success,
          counterQueues: event.counters,
        ),
      );
    } catch (e) {
      logger.e("Fail to load counter queues: $e", exception: e);
    }
  }
}
