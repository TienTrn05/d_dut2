part of 'community_activity_bloc.dart';

class CommunityActivityEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadAllActivities extends CommunityActivityEvent {
  final String token;
  final String keyword;
  final String? status;
  final String? categoryIds;
  final DateTime? startDate;
  final DateTime? endDate;
  final int minScrore;
  final int maxScore;
  final int pageNumber;

  LoadAllActivities(
      {required this.token,
      required this.keyword,
      required this.pageNumber,
      required this.status,
      required this.categoryIds,
      required this.startDate,
      required this.endDate,
      required this.minScrore,
      required this.maxScore});
}

class LoadAcademicYears extends CommunityActivityEvent {
  final String token;

  LoadAcademicYears({required this.token});
}

class LoadUserActivities extends CommunityActivityEvent {
  final String token;
  final String keyword;
  final String academicYearId;
  final String? status;
  final int pageNumber;

  LoadUserActivities(
      {required this.token,
      required this.keyword,
      required this.academicYearId,
      required this.status,
      required this.pageNumber});
}

class LoadDetailActivity extends CommunityActivityEvent {
  final ActivityModel activity;

  LoadDetailActivity({required this.activity});
}

class RegistActivity extends CommunityActivityEvent {
  final String token;
  final String keyword;
  final int pageNumber;
  final String? status;
  final String? categoryIds;
  final DateTime? startDate;
  final DateTime? endDate;
  final int minScrore;
  final int maxScore;
  final String idActivity;

  RegistActivity(
      {required this.token,
      required this.keyword,
      required this.pageNumber,
      required this.status,
      required this.categoryIds,
      required this.startDate,
      required this.endDate,
      required this.minScrore,
      required this.maxScore,
      required this.idActivity});
}

class ReRegistActivity extends CommunityActivityEvent {
  final String token;
  final String keyword;
  final String academicYearId;
  final String? status;
  final int pageNumber;
  final String idActivity;

  ReRegistActivity(
      {required this.token,
      required this.keyword,
      required this.academicYearId,
      required this.status,
      required this.idActivity,
      required this.pageNumber});
}

class CancelRegistration extends CommunityActivityEvent {
  final String token;
  final String keyword;
  final String academicYearId;
  final String? status;
  final int pageNumber;
  final String idActivity;

  CancelRegistration(
      {required this.token,
      required this.keyword,
      required this.academicYearId,
      required this.status,
      required this.idActivity,
      required this.pageNumber});
}

class SubmitProof extends CommunityActivityEvent {
  final String token;
  final String keyword;
  final String academicYearId;
  final String? status;
  final int pageNumber;
  final String idRegistration;
  final File image;
  final String? description;

  SubmitProof(
      {required this.token,
      required this.keyword,
      required this.academicYearId,
      required this.status,
      required this.pageNumber,
      required this.idRegistration,
      required this.image,
      this.description});
}

class UpdateUserActivitiesAfterSubmit extends CommunityActivityEvent {
  final UserActivitiesPagedModel activities;
  final List<AcademicYearModel> academicYears;

  UpdateUserActivitiesAfterSubmit(
      {required this.activities, required this.academicYears});
}

class LoadUserProofs extends CommunityActivityEvent {
  final String token;
  final String keyword;
  final int pageNumber;
  final String academicYearId;
  final String? status;

  LoadUserProofs(
      {required this.keyword,
      required this.token,
      required this.pageNumber,
      required this.academicYearId,
      required this.status});
}

class LoadUserScores extends CommunityActivityEvent {
  final String token;
  final String keyword;
  final String academicYearId;

  LoadUserScores(
      {required this.token,
      required this.keyword,
      required this.academicYearId});
}
