class MajorModel {
  final String id;
  final String majorName;
  final String majorNameEn;

  MajorModel(
      {required this.id, required this.majorName, required this.majorNameEn});

  factory MajorModel.fromJson(Map<String, dynamic> json) {
    return MajorModel(
        id: json['id'] ?? '',
        majorName: json['majorName'] ?? '',
        majorNameEn: json['majorNameEn'] ?? '');
  }
}
