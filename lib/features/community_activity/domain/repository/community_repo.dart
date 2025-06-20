import 'package:e_dut/features/community_activity/data/data_sources/remote_data_source/community_service.dart';
import 'package:e_dut/features/community_activity/data/model/activity_model.dart';
import 'package:e_dut/features/community_activity/data/model/category_model.dart';
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
}
