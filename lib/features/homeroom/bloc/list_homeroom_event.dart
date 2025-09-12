part of 'list_homeroom_bloc.dart';

class ListHomeroomEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ListHomeroomSubscriptionRequested extends ListHomeroomEvent {
  final String token;

  ListHomeroomSubscriptionRequested({required this.token});
}
