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
  final ActivitiesPagedModel pagedActivities;
  final List<CategoryModel> categories;

  AllActivitiesLoaded(this.pagedActivities, this.categories);
}

class AcademicYearsLoaded extends CommunityActivityState {
  final List<AcademicYearModel> academicYears;

  AcademicYearsLoaded({required this.academicYears});
}

class UserActivitiesLoaded extends CommunityActivityState {
  final List<AcademicYearModel> academicYears;
  final UserActivitiesPagedModel pagedActivities;

  UserActivitiesLoaded(this.academicYears, this.pagedActivities);
}

class ProofSubmitted extends CommunityActivityState {
  final bool success;
  final String? message;
  final UserActivitiesPagedModel updatedActivities;

  ProofSubmitted(
      {required this.success, this.message, required this.updatedActivities});
}

class UserProofsLoaded extends CommunityActivityState {
  final ProofsPagedModel userProofs;

  UserProofsLoaded(this.userProofs);
}

class UserScoresLoaded extends CommunityActivityState {
  final List<UserProofModel> userScores;

  UserScoresLoaded(this.userScores);
}
