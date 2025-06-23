part of 'all_activities_bloc.dart';

class AllActivitiesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadActivities extends AllActivitiesEvent {
  final String token;
  final String keyword;

  LoadActivities({required this.token, required this.keyword});
}

class RegistActivity extends AllActivitiesEvent {
  final String token;
  final String keyword;
  final String idActivity;

  RegistActivity(
      {required this.token, required this.keyword, required this.idActivity});
}
