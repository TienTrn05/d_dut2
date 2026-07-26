import 'package:e_dut/features/academic/models/plo_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/plo_repository.dart';
import '../data/stats_repository.dart';
import '../models/stats_model.dart';

part 'stats_event.dart';
part 'stats_state.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  StatsBloc(this._repo, this._ploRepository)
    : super(const StatsState.loading()) {
    on<StatsRequested>(_onRequested);
    on<StatsRefreshed>(_onRequested);
  }

  final StatsRepository _repo;
  final PLORepository _ploRepository;

  Future<void> _onRequested(StatsEvent event, Emitter<StatsState> emit) async {
    emit(const StatsState.loading());
    try {
      final stats = await _repo.fetchStats(authToken: event.authToken ?? '');
      final plo = await _ploRepository.getPLO(event.authToken ?? '');
      emit(StatsState.loaded(stats, plo));
    } catch (e) {
      emit(StatsState.error(e.toString()));
    }
  }
}
