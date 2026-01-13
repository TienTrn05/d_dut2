import 'package:e_dut/features/queue/data/models/ticket_model.dart';

class CounterQueueModel {
  final String idCounter;
  final int noCounter;
  final String departmentName;
  final int sessionStatus;
  final String sessionStatusDesc;
  final List<TicketModel> queueNoTickets;

  CounterQueueModel({
    required this.idCounter,
    required this.noCounter,
    required this.departmentName,
    required this.sessionStatus,
    required this.sessionStatusDesc,
    required this.queueNoTickets,
  });

  factory CounterQueueModel.fromJson(Map<String, dynamic> json) {
    return CounterQueueModel(
      idCounter: json['idCounter'] as String,
      noCounter: json['noCounter'] as int,
      departmentName: json['departmentName'] as String,
      sessionStatus: json['sessionStatus'] as int,
      sessionStatusDesc: json['sessionStatusDesc'],
      queueNoTickets:
          (json['queueNoTickets'] as List<dynamic>?)
              ?.map((item) => TicketModel.fromJson(item))
              .toList() ??
          [],
    );
  }
}
