import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../auth/data/model/scope_model.dart';
import '../domain/repository/dashboard_repo.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepo _dashboardRepository;

  DashboardBloc(this._dashboardRepository) : super(DashboardInitial()) {
    on<DashboardResetNavigation>(_onDashboardResetNavigation);
    on<DashboardNavigateRequested>(_onDashboardNavigate);
  }

  void _onDashboardResetNavigation(DashboardResetNavigation event, Emitter<DashboardState> emit) {
    emit(DashboardInitial());
  }

  void _onDashboardNavigate(DashboardNavigateRequested event, Emitter<DashboardState> emit) {
    if (_dashboardRepository.isPermissionGranted(event.scopes, event.routeName)){
      emit(DashboardNavigateSuccess(event.routeName));
    } else {
      emit(DashboardPermissionRequested("no-permission"));
    }
  }
}
