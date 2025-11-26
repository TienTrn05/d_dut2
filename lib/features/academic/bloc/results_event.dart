import 'package:equatable/equatable.dart';

abstract class ResultsEvent extends Equatable {
  const ResultsEvent();
  @override
  List<Object?> get props => [];
}

class LoadResults extends ResultsEvent {
  final String authToken;
  const LoadResults(this.authToken);

  @override
  List<Object?> get props => [authToken];
}

class NextSemesterPressed extends ResultsEvent {}

class PreviousSemesterPressed extends ResultsEvent {}
