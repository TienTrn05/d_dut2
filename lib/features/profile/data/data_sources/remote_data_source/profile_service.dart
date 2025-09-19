import 'package:dio/dio.dart';
import 'package:e_dut/features/homeroom/data/model/noti_model.dart';
import 'package:injectable/injectable.dart';

import '/core/services/api_client.dart';
import '/common/utils/logger.dart';

import '../../model/student_profile_model.dart';
import '../../model/teacher_profile_model.dart';

@injectable
class ProfileService {
  final String _url;
  final ApiClient _apiClient;

  ProfileService(@Named('profileAPIUrl') String url)
      : _url = url,
        _apiClient = ApiClient(url);

  Future<StudentProfileModel> getStudentProfile(String token) async {
    try {
      final response = await _apiClient.dio.get("$_url/api/profile",
          options: Options(headers: {
            "Authorization": "Bearer $token",
          }));

      if (response.statusCode != 200) {
        throw Exception("Failed to get student profile: ${response.data}");
      }

      final data = response.data['data'];
      return StudentProfileModel(
        fullName: data['fullName'],
        address: data['address'] ?? '',
        phoneNumber: data['phoneNumber'] ?? 'Không có',
        city: data['city'] ?? '',
        dateOfBirth:
            data['birthday'] != null ? DateTime.parse(data['birthday']) : null,
        gender: (data['gender'] as num) == 1 ? "Nam" : "Nữ",
        homeroomId: data['class']['id'],
        homeroom: data['class']['name'] ?? '',
        major: data['program']['major']['majorName'] ?? '',
        personalEmail: "Không có",
        relativeName: "data['relative_name']",
        relativePhoneNumber: "data['relative_phone_number']",
        trainingProgram: data['program']['academicProgramName'] ?? '',
        office365Account: "data['office365_account']",
        studentCode: data['studentCardNumber'],
        ward: "data['ward']",
      );
    } catch (e) {
      logger.e("Error getting student profile: $e");
      rethrow;
    }
  }

  Future<TeacherProfileModel> getTeacherProfile(String token) async {
    try {
      final response = await _apiClient.dio.get("$_url/api/profile/lecturer",
          options: Options(headers: {
            "Authorization": "Bearer $token",
          }));

      if (response.statusCode != 200) {
        throw Exception("Failed to get teacher profile: ${response.data}");
      }

      final data = response.data['data'];
      return TeacherProfileModel(
        // Thông tin cơ bản
        fullName: data['fullName'],
        email: "dtb@dut.udn.vn",
        dateOfBirth:
            data['birthday'] != null ? DateTime.parse(data['birthday']) : null,
        employeeId: "CBVC001",
        address: data['address'] ?? '',

        // Thông tin công tác
        degree: "Tiến sĩ",
        academicTitle: "Phó Giáo sư",
        department: data['faculty']['facultyName'] ?? '',
        position: "Giảng viên cao cấp",
        yearsOfService: 10,
        salaryCoefficient: 4.5,
        bankAccount: "0123456789",

        // Thông tin học vấn
        bachelorDegreeField: "...",
        bachelorGraduationYear: 2006,
        bachelorCountry: "Việt Nam",

        masterDegreeField: "...",
        masterGraduationYear: 2010,
        masterCountry: "Việt Nam",

        doctorateField: "Công nghệ phần mềm",
        doctorateGraduationYear: 2015,
        doctorateCountry: "Việt Nam",
      );
    } catch (e) {
      logger.e("Error getting teacher profile: $e");
      rethrow;
    }
  }

  Future<String> createNotification(
      String token, String classId, String title, String content) async {
    try {
      final response = await _apiClient.dio.post(
        "$_url/api/notifications/create",
        options: Options(headers: {
          "Authorization": "Bearer $token",
        }),
        data: {"classId": classId, "title": title, "content": content, "lecturerId": ""},
      );

      if (response.statusCode == 200) {
        final String data = response.data['data'];

        // notificationId
        return data;
      } else {
        throw Exception(
          "Failed to create notification: ${response.data['message']}",
        );
      }
    } catch (e) {
      logger.e("Failed to create notification: $e");
      throw Exception("Failed to create notification: $e");
    }
  }

  Future<List<NotiModel>> getNotificationsByClassId(
    String token,
    String classId,
  ) async {
    try {
      final response = await _apiClient.dio.get(
        "$_url/api/notifications",
        options: Options(headers: {
          "Authorization": "Bearer $token",
        }),
        queryParameters: {"classId": classId},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];

        // map sang list
        return data
            .map((e) => NotiModel(
                id: e['id'],
                title: e['title'],
                content: e['content'],
                date: DateTime.parse(e['createdAt'])))
            .toList();
      } else {
        throw Exception(
          "Failed to get notifications by classId: ${response.data['message']}",
        );
      }
    } catch (e) {
      logger.e("Error fetching notifications by classId: $e");
      throw Exception("Failed to fetch notifications by classId: $e");
    }
  }
}
