class AcademicYearModel {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;

  AcademicYearModel(
      {required this.id,
      required this.name,
      required this.startDate,
      required this.endDate});

  factory AcademicYearModel.fromJson(Map<String, dynamic> json) {
    return AcademicYearModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        startDate: DateTime.parse(json['startDate']),
        endDate: DateTime.parse(json['endDate']));
  }
}
