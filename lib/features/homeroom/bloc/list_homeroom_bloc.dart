import 'package:e_dut/features/homeroom/data/model/homeroom_model.dart';
import 'package:e_dut/features/homeroom/domain/repository/homeroom_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'list_homeroom_event.dart';
part 'list_homeroom_state.dart';

class ListHomeroomBloc extends Bloc<ListHomeroomEvent, ListHomeroomState> {
  final HomeroomRepository _repository;

  ListHomeroomBloc(this._repository) : super(ListHomeroomInitial()) {
    on<ListHomeroomSubscriptionRequested>(_onLoad);
  }

  Future<void> _onLoad(ListHomeroomSubscriptionRequested event,
      Emitter<ListHomeroomState> emit) async {
    emit(ListHomeroomLoading());

    try {
      final token = event.token;

      final homerooms = await _repository.getHomerooms(token);

      emit(ListHomeroomLoaded(homerooms: homerooms));
    } catch (e) {
      emit(ListHomeroomError(e.toString()));
    }
  }
}
