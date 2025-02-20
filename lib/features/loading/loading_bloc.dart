import 'package:flutter_bloc/flutter_bloc.dart';

// Sự kiện (Event)
abstract class LoadingEvent {}

class LoadingShow extends LoadingEvent {}

class LoadingHide extends LoadingEvent {}

// Trạng thái (State)
class LoadingState {
  final bool isLoading;
  LoadingState(this.isLoading);
}

// BLoC xử lý Loading
class LoadingBloc extends Bloc<LoadingEvent, LoadingState> {
  LoadingBloc() : super(LoadingState(false)) {
    on<LoadingShow>((event, emit) => emit(LoadingState(true)));
    on<LoadingHide>((event, emit) => emit(LoadingState(false)));
  }
}
