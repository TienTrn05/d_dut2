import 'package:flutter_bloc/flutter_bloc.dart';

part 'root_event.dart';
part 'root_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  MainBloc() : super(MainState(0)) {
    on<ChangePage>((event, emit) => emit(MainState(event.pageIndex)));
  }
}