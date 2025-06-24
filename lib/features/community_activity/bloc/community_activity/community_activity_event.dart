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

class RegistActivity extends CommunityActivityEvent {
  final String token;
  final String keyword;
  final String idActivity;

  RegistActivity(
      {required this.token, required this.keyword, required this.idActivity});
}
