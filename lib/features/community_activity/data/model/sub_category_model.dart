class SubCategoryModel {
  final String id;
  final String name;
  final int minScore;
  final int maxScore;
  final String categoryId;

  SubCategoryModel({
    required this.id,
    required this.name,
    required this.minScore,
    required this.maxScore,
    required this.categoryId,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json,
      {required String categoryId}) {
    return SubCategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      minScore: json['minScore'] is int
          ? json['minScore']
          : int.tryParse(json['minScore']?.toString() ?? '0') ?? 0,
      maxScore: json['maxScore'] is int
          ? json['maxScore']
          : int.tryParse(json['maxScore']?.toString() ?? '0') ?? 0,
      categoryId: categoryId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'minScore': minScore,
        'maxScore': maxScore,
        'categoryId': categoryId,
      };
}
