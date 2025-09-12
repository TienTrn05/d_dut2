part of 'list_homeroom_bloc.dart';

class ListHomeroomState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ListHomeroomInitial extends ListHomeroomState {}

class ListHomeroomLoading extends ListHomeroomState {}

class ListHomeroomError extends ListHomeroomState {
  final String message;
  ListHomeroomError(this.message);
  @override
  List<Object?> get props => [message];
}

class ListHomeroomLoaded extends ListHomeroomState {
  final List<HomeroomModel> homerooms;

  ListHomeroomLoaded({required this.homerooms});
}
