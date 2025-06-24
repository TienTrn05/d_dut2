part of 'community_activity_bloc.dart';

class CommunityActivityState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CommunityActivityInitial extends CommunityActivityState {}

class CommunityActivityLoading extends CommunityActivityState {}

class CommunityActivityError extends CommunityActivityState {
  final String message;
  CommunityActivityError(this.message);
  @override
  List<Object?> get props => [message];
}

class AllActivitiesLoaded extends CommunityActivityState {
  final List<ActivityModel> activities;
  final List<CategoryModel> categories;

  AllActivitiesLoaded(this.activities, this.categories);
}

class UserActivitiesLoaded extends CommunityActivityState {
  final List<UserActivityModel> activities;

  UserActivitiesLoaded(this.activities);
}
