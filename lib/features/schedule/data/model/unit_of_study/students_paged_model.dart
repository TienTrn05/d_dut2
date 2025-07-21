import 'package:e_dut/features/schedule/data/model/role/student_model.dart';

class StudentsPagedModel {
  final int totalItems;
  final int pageSize;
  final int pageNumber;
  final List<StudentModel> items;

  StudentsPagedModel(
      {required this.totalItems,
      required this.pageSize,
      required this.pageNumber,
      required this.items});

  factory StudentsPagedModel.fromJson(Map<String, dynamic> json) {
    return StudentsPagedModel(
        totalItems: (json['totalItems'] as int?) ?? 0,
        pageSize: (json['pageSize'] as int?) ?? 0,
        pageNumber: (json['pageNumber'] as int?) ?? 0,
        items: (json['items'] as List<dynamic>?)
                ?.map((item) => StudentModel.fromJson(item))
                .toList() ??
            []);
  }
}
