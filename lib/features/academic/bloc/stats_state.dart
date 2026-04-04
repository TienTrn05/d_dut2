part of 'stats_bloc.dart';

class StatsState extends Equatable {
  final bool isLoading;
  final StatsModel? data;
  final List<PLOModel> plo;
  final String? error;

  const StatsState._({required this.isLoading, this.data, required this.plo, this.error});

  const StatsState.loading() : this._(isLoading: true, plo: const []);
  const StatsState.loaded(StatsModel data, List<PLOModel> plo)
      : this._(isLoading: false, data: data, plo: plo);
  const StatsState.error(String message)
      : this._(isLoading: false, plo: const [], error: message);

  @override
  List<Object?> get props => [isLoading, data, plo, error];
}
