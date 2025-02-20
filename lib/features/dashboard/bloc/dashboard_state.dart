part of 'dashboard_bloc.dart';

sealed class DashboardState extends Equatable {
  @override
  List<Object> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardNavigateSuccess extends DashboardState {
  final String routeName;

  DashboardNavigateSuccess(this.routeName);

  @override
  List<Object> get props => [routeName];
}

class DashboardPermissionRequested extends DashboardState {
  final String permission;

  DashboardPermissionRequested(this.permission);

  @override
  List<Object> get props => [permission];
}