part of 'queue_bloc.dart';

abstract class QueueEvent extends Equatable {
  const QueueEvent();

  @override
  List<Object?> get props => [];
}

class LoadQueueDataEvent extends QueueEvent {
  final String noGuest;

  const LoadQueueDataEvent({required this.noGuest});

  @override
  List<Object?> get props => [noGuest];
}

class _TicketsLoaded extends QueueEvent {
  final List<UserTicketModel> tickets;
  final bool hasError;
  const _TicketsLoaded(this.tickets, {this.hasError = false});
}

class _CountersLoaded extends QueueEvent {
  final List<CounterQueueModel> counters;
  final bool hasError;
  const _CountersLoaded(this.counters, {this.hasError = false});
}
