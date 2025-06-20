import 'package:e_dut/features/community_activity/data/model/sub_category_model.dart';

class CategoryModel {
  final String id;
  final String name;
  final int index;
  final List<SubCategoryModel> subcategories;

  CategoryModel({
    required this.id,
    required this.name,
    required this.index,
    required this.subcategories,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    return CategoryModel(
      id: id,
      name: json['name']?.toString() ?? '',
      index: json['index'] is int
          ? json['index']
          : int.tryParse(json['index']?.toString() ?? '0') ?? 0,
      subcategories: (json['subcategories'] as List? ?? [])
          .map((e) => SubCategoryModel.fromJson(e, categoryId: id))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'index': index,
        'subcategories': subcategories.map((e) => e.toJson()).toList(),
      };
}
