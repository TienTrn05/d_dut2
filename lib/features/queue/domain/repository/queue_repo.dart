import 'package:e_dut/features/queue/data/data_sources/remote_data_source/queue_service.dart';
import 'package:e_dut/features/queue/data/models/counter_queue_model.dart';
import 'package:e_dut/features/queue/data/models/user_ticket_model.dart';
import 'package:injectable/injectable.dart';

@singleton
class QueueRepository {
  final QueueService _queueService;

  QueueRepository(this._queueService);

  Future<List<CounterQueueModel>> getAllQueueCounter() async {
    return _queueService.getAllQueueCounter();
  }

  Future<List<UserTicketModel>> getUserTicketsToday(String noGuest) async {
    return _queueService.getUserTicketsToday(noGuest);
  }
}
