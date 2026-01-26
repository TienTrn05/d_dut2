enum TicketStatus {
  inactive(0),
  created(1),
  waiting(2),
  processing(3),
  completed(4),
  skipped(5);

  final int value;
  const TicketStatus(this.value);
  static TicketStatus fromInt(int val) {
    return TicketStatus.values.firstWhere(
      (e) => e.value == val,
      orElse: () => TicketStatus.inactive,
    );
  }

  bool get isProcessing => this == TicketStatus.processing;
  bool get isFinished =>
      this == TicketStatus.completed || this == TicketStatus.skipped;
}
