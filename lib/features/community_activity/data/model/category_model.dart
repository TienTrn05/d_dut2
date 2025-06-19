class CategoryModel {
  final String id;
  final String name;
  final int index;

  CategoryModel({required this.id, required this.name, required this.index});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
        id: json['id'], name: json['name'], index: json['index']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'index': index};
  }
}
