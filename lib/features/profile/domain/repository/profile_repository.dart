import 'package:injectable/injectable.dart';

import '../../data/data_sources/remote_data_source/profile_service.dart';
import '../../data/model/student_profile_model.dart';

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
}
