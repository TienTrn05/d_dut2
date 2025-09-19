import 'package:injectable/injectable.dart';

import '../../../homeroom/data/model/noti_model.dart';
import '../../data/data_sources/remote_data_source/profile_service.dart';
import '../../data/model/student_profile_model.dart';
import '../../data/model/teacher_profile_model.dart';

@injectable
class ProfileRepository {
  final ProfileService _profileService;

  ProfileRepository(this._profileService);

  Future<StudentProfileModel> getStudentProfile(String token) async {
    try {
      return await _profileService.getStudentProfile(token);
    } catch (e) {
      throw Exception('Failed to get student profile: $e');
    }
  }

  Future<TeacherProfileModel> getTeacherProfile(String token) async {
    try {
      return await _profileService.getTeacherProfile(token);
    } catch (e) {
      throw Exception('Failed to get teacher profile: $e');
    }
  }

  Future<String> createNotification(String token, String classId, String title, String content) {
    return _profileService.createNotification(token, classId, title, content);
  }

  Future<List<NotiModel>> getNotificationsByClassId(String token, String classId) async {
    return _profileService.getNotificationsByClassId(token, classId);
  }
}
