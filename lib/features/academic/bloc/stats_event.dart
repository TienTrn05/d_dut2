part of 'stats_bloc.dart';

abstract class StatsEvent extends Equatable {
  const StatsEvent({this.authToken});
  final String? authToken;

  @override
  List<Object?> get props => [authToken];
}

class StatsRequested extends StatsEvent {
  const StatsRequested({String? authToken}) : super(authToken: authToken);
}

class StatsRefreshed extends StatsEvent {
  const StatsRefreshed({String? authToken}) : super(authToken: authToken);
}
