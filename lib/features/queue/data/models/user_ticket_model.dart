class UserTicketModel {
  final String idTicket;
  final String idCouter;
  final int noTicket;
  final int noCounter;
  final String serviceName;
  final int? countBeforeMe;
  final int ticketStatus;
  final String ticketStatusDesc;

  UserTicketModel({
    required this.idTicket,
    required this.idCouter,
    required this.noTicket,
    required this.noCounter,
    required this.serviceName,
    this.countBeforeMe,
    required this.ticketStatus,
    required this.ticketStatusDesc,
  });

  factory UserTicketModel.fromJson(Map<String, dynamic> json) {
    return UserTicketModel(
      idTicket: json['idTicket'] as String,
      idCouter: json['idCounter'] as String,
      noTicket: json['noTicket'] as int,
      noCounter: json['noCounter'] as int,
      serviceName: json['serviceName'] as String,
      countBeforeMe: json['countBeforeMe'] as int?,
      ticketStatus: json['ticketStatus'] as int,
      ticketStatusDesc: json['ticketStatusDesc'] as String,
    );
  }
}
