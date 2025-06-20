part of 'all_activities_bloc.dart';

class AllActivitiesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AllActivitiesInitial extends AllActivitiesState {}

class AllActivitiesLoading extends AllActivitiesState {}

class AllActivitiesError extends AllActivitiesState {
  final String message;
  AllActivitiesError(this.message);
  @override
  List<Object?> get props => [message];
}

class AllActivitiesLoaded extends AllActivitiesState {
  final List<ActivityModel> activities;
  final List<CategoryModel> categories;

  AllActivitiesLoaded(this.activities, this.categories);
}
