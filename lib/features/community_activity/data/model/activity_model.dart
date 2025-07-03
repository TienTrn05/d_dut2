import 'package:e_dut/features/community_activity/data/model/sub_category_model.dart';

class ActivityModel {
  final String id;
  final String name;
  final int score;
  final String? description;
  final String? image;
  final int maxParticipants;
  final int participants;
  final String address;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime startRegistration;
  final DateTime endRegistration;
  final bool isExternal;
  final SubCategoryModel subcategory;
  final String? status;
  final String createdBy;

  ActivityModel(
      {required this.id,
      required this.name,
      required this.score,
      this.description,
      this.image,
      required this.maxParticipants,
      required this.participants,
      required this.address,
      required this.startDate,
      required this.endDate,
      required this.startRegistration,
      required this.endRegistration,
      required this.isExternal,
      required this.subcategory,
      this.status,
      required this.createdBy});

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    final subJson = json['subcategory'] ?? {};
    final categoryId = subJson['category']?['id']?.toString() ?? '';

    return ActivityModel(
      id: json['id'],
      name: json['name'],
      score: json['score'],
      description: json['description'],
      image: json['image'],
      maxParticipants: json['maxParticipants'],
      participants: json['participants'],
      address: json['address'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      startRegistration: DateTime.parse(json['startRegistration']),
      endRegistration: DateTime.parse(json['endRegistration']),
      isExternal: json['isExternal'],
      subcategory: SubCategoryModel.fromJson(subJson, categoryId: categoryId),
      status: json.containsKey('status') ? json['status'] : null,
      createdBy: json['createdBy']?['name']?.toString() ??
          'Đoàn Thanh niên Trường Đại học Bách khoa - ĐHĐN',
    );
  }
  @override
  String toString() {
    return 'ActivityModel(id: $id, name: $name, status: $status)';
  }
  // Map<String, dynamic> toJson() {
  //   return {
  //     'id': id,
  //     'name': name,
  //     'score': score,
  //     'description': description,
  //     'image': image,
  //     'maxParticipants': maxParticipants,
  //     'participants': participants,
  //     'address': address,
  //     'organization': organization,
  //     'startDate': startDate,
  //     'endDate': endDate,
  //     'startRegistration': startRegistration,
  //     'endRegistration': endRegistration,
  //     'isExternal': isExternal,
  //     'subcategory': subcategory.toJson(),
  //     'status': status
  //   };
  // }
}
