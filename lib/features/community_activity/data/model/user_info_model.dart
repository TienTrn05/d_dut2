import 'package:e_dut/features/community_activity/data/model/clazz_model.dart';
import 'package:e_dut/features/community_activity/data/model/user_role_model.dart';

class UserInfoModel {
  final String id;
  final String username;
  final String studentId;
  final String name;
  final String? email;
  final String? avatar;
  final String? phoneNumber;
  final String? score;
  final String? deletedAt;
  final UserRoleModel role;
  final ClazzModel clazz;
  final String? faculty;

  UserInfoModel({
    required this.id,
    required this.username,
    required this.studentId,
    required this.name,
    this.email,
    this.avatar,
    this.phoneNumber,
    this.score,
    this.deletedAt,
    required this.role,
    required this.clazz,
    this.faculty,
  });

  factory UserInfoModel.fromJson(Map<String, dynamic> json) {
    return UserInfoModel(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      studentId: json['studentId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      avatar: json['avatar']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      score: json['score']?.toString(),
      deletedAt: json['deletedAt']?.toString(),
      role: UserRoleModel.fromJson(json['role'] ?? {}),
      clazz: ClazzModel.fromjson(json['clazz'] ?? {}),
      // Fix: Thêm null check cho faculty
      faculty: json['faculty']?.toString(),
    );
  }
}
