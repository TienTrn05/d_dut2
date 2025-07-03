import 'dart:io';

import 'package:e_dut/features/community_activity/data/data_sources/remote_data_source/community_service.dart';
import 'package:e_dut/features/community_activity/data/model/activity_model.dart';
import 'package:e_dut/features/community_activity/data/model/category_model.dart';
import 'package:e_dut/features/community_activity/data/model/user_activity_model.dart';
import 'package:e_dut/features/community_activity/data/model/user_info_model.dart';
import 'package:e_dut/features/community_activity/data/model/user_proof_model.dart';
import 'package:injectable/injectable.dart';

@injectable
class CommunityRepository {
  final CommunityService _communityService;

  CommunityRepository(this._communityService);

  Future<List<ActivityModel>> getActivities(
      String token, String keyword) async {
    return _communityService.getActivities(token, keyword);
  }

  Future<List<CategoryModel>> getCategories(String token, String keyword) {
    return _communityService.getCategories(token, keyword);
  }

  Future<UserInfoModel> getUserInfo(String token) {
    return _communityService.getUserInfo(token);
  }

  Future<bool> registActivity(String token, String idActivity) {
    return _communityService.registActivity(token, idActivity);
  }

  Future<List<UserActivityModel>> getUserActivities(
      String token, String keyword) {
    return _communityService.getUserActivities(token, keyword);
  }

  Future<bool> cancelRegistration(String token, String idActivity) {
    return _communityService.cancelRegistration(token, idActivity);
  }

  Future<bool> submitProof(
    String token,
    String idRegistration,
    File imageFile,
    String? description,
  ) {
    return _communityService.submitProof(
        token, idRegistration, imageFile, description);
  }

  Future<List<UserProofModel>> getUserProofs(String token, String keyword) {
    return _communityService.getUserProofs(token, keyword);
  }
}
