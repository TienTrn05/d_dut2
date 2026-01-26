part of 'queue_bloc.dart';

enum QueueStatus { initial, loading, success, failure, refreshing }

class QueueState extends Equatable {
  final QueueStatus ticketsStatus;
  final QueueStatus countersStatus;
  final List<UserTicketModel> userTickets;
  final List<CounterQueueModel> counterQueues;

  const QueueState({
    this.ticketsStatus = QueueStatus.initial,
    this.countersStatus = QueueStatus.initial,
    this.userTickets = const [],
    this.counterQueues = const [],
  });

  QueueState copyWith({
    QueueStatus? ticketsStatus,
    QueueStatus? countersStatus,
    List<UserTicketModel>? userTickets,
    List<CounterQueueModel>? counterQueues,
  }) {
    return QueueState(
      ticketsStatus: ticketsStatus ?? this.ticketsStatus,
      countersStatus: countersStatus ?? this.countersStatus,
      userTickets: userTickets ?? this.userTickets,
      counterQueues: counterQueues ?? this.counterQueues,
    );
  }

  @override
  List<Object?> get props => [
    ticketsStatus,
    countersStatus,
    userTickets,
    counterQueues,
  ];
}
