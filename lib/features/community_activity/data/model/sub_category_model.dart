import 'package:e_dut/features/community_activity/data/model/category_model.dart';

class SubCategoryModel {
  final String id;
  final String name;
  final int minScore;
  final int maxScore;
  final CategoryModel? category;

  SubCategoryModel({
    required this.id,
    required this.name,
    required this.minScore,
    required this.maxScore,
    required this.category,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
        id: json['id'],
        name: json['name'],
        minScore: json['minScore'],
        maxScore: json['maxScore'],
        category: json['category'] != null
            ? CategoryModel.fromJson(json['category'])
            : null);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'minScore': minScore,
      'maxScore': maxScore,
      'category': category?.toJson()
    };
  }
}
