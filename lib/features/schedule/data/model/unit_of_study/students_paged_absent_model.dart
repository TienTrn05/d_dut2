import 'package:e_dut/features/schedule/data/model/role/student_absent_model.dart';

class StudentsPagedAbsentModel {
  final int totalItems;
  final int pageSize;
  final int pageNumber;
  final List<StudentAbsentModel> items;

  StudentsPagedAbsentModel(
      {required this.totalItems,
      required this.pageSize,
      required this.pageNumber,
      required this.items});

  factory StudentsPagedAbsentModel.fromJson(Map<String, dynamic> json) {
    return StudentsPagedAbsentModel(
        totalItems: (json['totalItems'] as int?) ?? 0,
        pageSize: (json['pageSize'] as int?) ?? 0,
        pageNumber: (json['pageNumber'] as int?) ?? 0,
        items: (json['items'] as List<dynamic>?)
                ?.map((item) => StudentAbsentModel.fromJson(item))
                .toList() ??
            []);
  }
}
