class Lecturer {
  final String id;
  final String fullName;
  final String facultyId;

  Lecturer({
    required this.id,
    required this.fullName,
    required this.facultyId,
  });

  factory Lecturer.fromJson(Map<String, dynamic> json) {
    return Lecturer(
      id: json['id'],
      fullName: json['fullName'],
      facultyId: json['facultyId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'facultyId': facultyId,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Lecturer && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
