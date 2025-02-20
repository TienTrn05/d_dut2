part of 'dashboard_bloc.dart';

class DashboardEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class DashboardNavigateRequested extends DashboardEvent {
  final List<String> scopes;
  final String routeName;

  DashboardNavigateRequested(this.scopes, this.routeName);

  @override
  List<Object> get props => [scopes, routeName];
}

class DashboardResetNavigation extends DashboardEvent {}