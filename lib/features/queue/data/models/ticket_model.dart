class TicketModel {
  final int noTicket;
  final int ticketStatus;
  final String ticketStatusDesc;

  TicketModel({
    required this.noTicket,
    required this.ticketStatus,
    required this.ticketStatusDesc,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      noTicket: json['noTicket'] as int,
      ticketStatus: json['ticketStatus'] as int,
      ticketStatusDesc: json['ticketStatusDesc'] as String,
    );
  }
}
