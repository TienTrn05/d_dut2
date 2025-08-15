import 'dart:io';

import 'package:e_dut/features/community_activity/data/data_sources/remote_data_source/community_service.dart';
import 'package:e_dut/features/community_activity/data/model/academic_year_model.dart';
import 'package:e_dut/features/community_activity/data/model/paged/activities_paged_model.dart';
import 'package:e_dut/features/community_activity/data/model/category_model.dart';
import 'package:e_dut/features/community_activity/data/model/paged/proofs_paged_model.dart';
import 'package:e_dut/features/community_activity/data/model/paged/user_activities_paged_model.dart';
import 'package:e_dut/features/community_activity/data/model/user_info_model.dart';
import 'package:e_dut/features/community_activity/data/model/user_proof_model.dart';
import 'package:injectable/injectable.dart';

@injectable
class CommunityRepository {
  final CommunityService _communityService;

  CommunityRepository(this._communityService);

  Future<ActivitiesPagedModel> getActivities(
    String token,
    String keyword,
    int pageNumber,
    String? status,
    String? categoryIds,
    DateTime? startDate,
    DateTime? endDate,
    int minScrore,
    int maxScore,
  ) async {
    return _communityService.getActivities(token, keyword, pageNumber, status,
        categoryIds, startDate, endDate, minScrore, maxScore);
  }

  Future<List<CategoryModel>> getCategories(String token, String keyword) {
    return _communityService.getCategories(token, keyword);
  }

  Future<List<AcademicYearModel>> getAcademicYears(String token) {
    return _communityService.getAcademicYears(token);
  }

  Future<UserInfoModel> getUserInfo(String token) {
    return _communityService.getUserInfo(token);
  }

  Future<bool> registActivity(String token, String idActivity) {
    return _communityService.registActivity(token, idActivity);
  }

  Future<UserActivitiesPagedModel> getUserActivities(
    String token,
    String keyword,
    String academicYearId,
    String? status,
    int pageNumber,
  ) {
    return _communityService.getUserActivities(
        token, keyword, academicYearId, status, pageNumber);
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

  Future<ProofsPagedModel> getUserProofs(String token, String keyword,
      int pageNumber, String academicYearId, String? status) {
    return _communityService.getUserProofs(
        token, keyword, pageNumber, academicYearId, status);
  }

  Future<List<UserProofModel>> getUserScores(
      String token, String keyword, String academicYearId) {
    return _communityService.getUserScores(token, keyword, academicYearId);
  }
}
