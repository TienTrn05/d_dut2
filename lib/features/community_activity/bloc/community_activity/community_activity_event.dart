part of 'community_activity_bloc.dart';

class CommunityActivityEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadAllActivities extends CommunityActivityEvent {
  final String token;
  final String keyword;

  LoadAllActivities({required this.token, required this.keyword});
}

class LoadUserActivities extends CommunityActivityEvent {
  final String token;
  final String keyword;

  LoadUserActivities({required this.token, required this.keyword});
}

class LoadDetailActivity extends CommunityActivityEvent {
  final ActivityModel activity;

  LoadDetailActivity({required this.activity});
}

class RegistActivity extends CommunityActivityEvent {
  final String token;
  final String keyword;
  final String idActivity;

  RegistActivity(
      {required this.token, required this.keyword, required this.idActivity});
}

class ReRegistActivity extends CommunityActivityEvent {
  final String token;
  final String keyword;
  final String idActivity;

  ReRegistActivity(
      {required this.token, required this.keyword, required this.idActivity});
}

class CancelRegistration extends CommunityActivityEvent {
  final String token;
  final String keyword;
  final String idActivity;

  CancelRegistration(
      {required this.token, required this.keyword, required this.idActivity});
}

class SubmitProof extends CommunityActivityEvent {
  final String token;
  final String keyword;
  final String idRegistration;
  final File image;
  final String? description;

  SubmitProof(
      {required this.token,
      required this.keyword,
      required this.idRegistration,
      required this.image,
      this.description});
}

class UpdateUserActivitiesAfterSubmit extends CommunityActivityEvent {
  final List<UserActivityModel> activities;

  UpdateUserActivitiesAfterSubmit({required this.activities});
}

class LoadUserProofs extends CommunityActivityEvent {
  final String token;
  final String keyword;

  LoadUserProofs({required this.keyword, required this.token});
}
