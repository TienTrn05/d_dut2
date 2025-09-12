import 'package:dio/dio.dart';
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
}
